package com.galmuri.diary

import android.content.Context
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.util.Base64
import java.io.File

class ScreenshotObserver(
    private val context: Context,
    private val onScreenshotCaptured: (ByteArray) -> Unit
) : ContentObserver(Handler(Looper.getMainLooper())) {

    private var lastScreenshotPath: String? = null
    private var lastCheckTime: Long = System.currentTimeMillis()

    override fun onChange(selfChange: Boolean, uri: Uri?) {
        super.onChange(selfChange, uri)
        
        // 스크린샷 감지
        detectScreenshot()
    }

    private fun detectScreenshot() {
        try {
            val projection = arrayOf(
                MediaStore.Images.Media.DATA,
                MediaStore.Images.Media.DATE_ADDED
            )

            val cursor = context.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection,
                "${MediaStore.Images.Media.DATE_ADDED} >= ?",
                arrayOf((lastCheckTime / 1000).toString()),
                "${MediaStore.Images.Media.DATE_ADDED} DESC"
            )

            cursor?.use {
                if (it.moveToFirst()) {
                    val dataColumn = it.getColumnIndex(MediaStore.Images.Media.DATA)
                    val path = it.getString(dataColumn)

                    // 스크린샷 경로 확인
                    if (path != null && isScreenshot(path) && path != lastScreenshotPath) {
                        lastScreenshotPath = path
                        lastCheckTime = System.currentTimeMillis()

                        // 스크린샷 파일 읽기
                        val file = File(path)
                        if (file.exists()) {
                            val bytes = file.readBytes()
                            onScreenshotCaptured(bytes)
                        }
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun isScreenshot(path: String): Boolean {
        val lowerPath = path.lowercase()
        return lowerPath.contains("screenshot") ||
               lowerPath.contains("screen") ||
               lowerPath.contains("스크린샷") ||
               lowerPath.contains("/pictures/screenshots/") ||
               lowerPath.contains("/dcim/screenshots/")
    }

    fun startObserving() {
        context.contentResolver.registerContentObserver(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            true,
            this
        )
    }

    fun stopObserving() {
        context.contentResolver.unregisterContentObserver(this)
    }
}

