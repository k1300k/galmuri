package com.galmuri.diary

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.Image
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.IBinder
import android.util.DisplayMetrics
import android.view.*
import android.widget.Button
import android.widget.LinearLayout
import androidx.core.app.NotificationCompat
import java.io.ByteArrayOutputStream

class OverlayService : Service() {
    private var overlayView: View? = null
    private var windowManager: WindowManager? = null
    private var mediaProjection: MediaProjection? = null
    private var mediaProjectionManager: MediaProjectionManager? = null
    private var imageReader: ImageReader? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var screenWidth = 0
    private var screenHeight = 0
    private var screenDensity = 0

    companion object {
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "overlay_service_channel"
    }

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        
        val displayMetrics = DisplayMetrics()
        windowManager?.defaultDisplay?.getMetrics(displayMetrics)
        screenWidth = displayMetrics.widthPixels
        screenHeight = displayMetrics.heightPixels
        screenDensity = displayMetrics.densityDpi
        
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "SHOW_OVERLAY" -> {
                val resultCode = intent.getIntExtra("resultCode", 0)
                val resultData = intent.getParcelableExtra<Intent>("data")
                showOverlayButton(resultCode, resultData)
            }
            "HIDE_OVERLAY" -> {
                hideOverlayButton()
            }
            "CAPTURE_SCREEN" -> {
                captureScreen()
            }
        }
        return START_NOT_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Overlay Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "화면 캡처 오버레이 서비스"
            }
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Galmuri Diary")
            .setContentText("화면 캡처 대기 중")
            .setSmallIcon(android.R.drawable.ic_menu_camera)
            .setOngoing(true)
            .build()
    }

    fun showOverlayButton(resultCode: Int, resultData: Intent?) {
        if (overlayView != null) {
            return // 이미 표시 중
        }

        // MediaProjection 설정
        if (resultCode != 0 && resultData != null) {
            mediaProjection = mediaProjectionManager?.getMediaProjection(resultCode, resultData)
        }

        // 오버레이 버튼 생성
        val button = Button(this).apply {
            text = "화면 캡처"
            setBackgroundColor(Color.parseColor("#FF0000"))
            setTextColor(Color.WHITE)
            textSize = 14f
            setPadding(32, 16, 32, 16)
            setOnClickListener {
                captureScreen()
            }
        }

        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                WindowManager.LayoutParams.TYPE_PHONE
            },
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            x = 0
            y = 100
        }

        overlayView = button
        windowManager?.addView(overlayView, layoutParams)
    }

    fun hideOverlayButton() {
        overlayView?.let {
            windowManager?.removeView(it)
            overlayView = null
        }
        stopSelf()
    }

    private fun captureScreen() {
        if (mediaProjection == null) {
            return
        }

        imageReader = ImageReader.newInstance(screenWidth, screenHeight, PixelFormat.RGBA_8888, 2)
        
        virtualDisplay = mediaProjection?.createVirtualDisplay(
            "ScreenCapture",
            screenWidth,
            screenHeight,
            screenDensity,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            imageReader?.surface,
            null,
            null
        )

        imageReader?.setOnImageAvailableListener({ reader ->
            val image = reader.acquireLatestImage()
            if (image != null) {
                val bitmap = imageToBitmap(image)
                val byteArray = bitmapToByteArray(bitmap)
                
                // MainActivity에 캡처 결과 전달
                MainActivity.getInstance()?.onScreenCaptured(byteArray)
                
                // 정리
                image.close()
                virtualDisplay?.release()
                imageReader?.close()
                mediaProjection?.stop()
                
                // 오버레이 숨기기
                hideOverlayButton()
                
                // 앱을 포그라운드로 가져오기
                val intent = packageManager.getLaunchIntentForPackage(packageName)
                intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                startActivity(intent)
            }
        }, null)
    }

    private fun imageToBitmap(image: Image): Bitmap {
        val planes = image.planes
        val buffer = planes[0].buffer
        val pixelStride = planes[0].pixelStride
        val rowStride = planes[0].rowStride
        val rowPadding = rowStride - pixelStride * screenWidth

        val bitmap = Bitmap.createBitmap(
            screenWidth + rowPadding / pixelStride,
            screenHeight,
            Bitmap.Config.ARGB_8888
        )
        bitmap.copyPixelsFromBuffer(buffer)
        
        return if (rowPadding == 0) {
            bitmap
        } else {
            Bitmap.createBitmap(bitmap, 0, 0, screenWidth, screenHeight)
        }
    }

    private fun bitmapToByteArray(bitmap: Bitmap): ByteArray {
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }

    override fun onDestroy() {
        super.onDestroy()
        hideOverlayButton()
    }
}

