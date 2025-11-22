package com.galmuri.diary

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.galmuri.diary/screen_capture"
    private val EVENT_CHANNEL = "com.galmuri.diary/screen_capture_events"
    private val REQUEST_MEDIA_PROJECTION = 1000
    private val REQUEST_OVERLAY_PERMISSION = 1001
    private var resultCallback: MethodChannel.Result? = null
    private var overlayResultCallback: MethodChannel.Result? = null
    private var pendingResultCode: Int = 0
    private var pendingData: Intent? = null
    private var eventSink: EventChannel.EventSink? = null

    companion object {
        private var instance: MainActivity? = null
        
        fun getInstance(): MainActivity? = instance
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        instance = this
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // EventChannel 설정
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestScreenCapture" -> {
                    requestScreenCapture(result)
                }
                "showOverlay" -> {
                    showOverlay(result)
                }
                "hideOverlay" -> {
                    hideOverlay(result)
                }
                "checkOverlayPermission" -> {
                    checkOverlayPermission(result)
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun requestScreenCapture(result: MethodChannel.Result) {
        resultCallback = result
        val mediaProjectionManager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        val captureIntent = mediaProjectionManager.createScreenCaptureIntent()
        startActivityForResult(captureIntent, REQUEST_MEDIA_PROJECTION)
    }

    private fun showOverlay(result: MethodChannel.Result) {
        overlayResultCallback = result
        
        // 오버레이 권한 확인
        if (!Settings.canDrawOverlays(this)) {
            result.error("PERMISSION_DENIED", "오버레이 권한이 필요합니다", null)
            return
        }

        // MediaProjection 권한 요청
        if (pendingResultCode == 0 || pendingData == null) {
            val mediaProjectionManager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
            val captureIntent = mediaProjectionManager.createScreenCaptureIntent()
            startActivityForResult(captureIntent, REQUEST_MEDIA_PROJECTION)
        } else {
            // 이미 권한이 있으면 바로 오버레이 표시
            startOverlayService(pendingResultCode, pendingData!!)
        }
    }

    private fun hideOverlay(result: MethodChannel.Result) {
        val intent = Intent(this, OverlayService::class.java).apply {
            action = "HIDE_OVERLAY"
        }
        startForegroundService(intent)
        result.success("overlay_hidden")
    }

    private fun checkOverlayPermission(result: MethodChannel.Result) {
        val hasPermission = Settings.canDrawOverlays(this)
        result.success(hasPermission)
    }

    private fun requestOverlayPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(this)) {
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:$packageName")
                )
                startActivityForResult(intent, REQUEST_OVERLAY_PERMISSION)
                result.success("permission_requested")
            } else {
                result.success("permission_granted")
            }
        } else {
            result.success("permission_granted")
        }
    }

    private fun startOverlayService(resultCode: Int, data: Intent) {
        val intent = Intent(this, OverlayService::class.java).apply {
            action = "SHOW_OVERLAY"
            putExtra("resultCode", resultCode)
            putExtra("data", data)
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
        
        // 앱을 백그라운드로 보내기
        moveTaskToBack(true)
        
        overlayResultCallback?.success("overlay_shown")
        overlayResultCallback = null
    }
    
    fun onScreenCaptured(imageBytes: ByteArray) {
        runOnUiThread {
            val base64 = Base64.encodeToString(imageBytes, Base64.NO_WRAP)
            eventSink?.success(mapOf(
                "type" to "screen_captured",
                "imageBase64" to base64
            ))
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        when (requestCode) {
            REQUEST_MEDIA_PROJECTION -> {
                if (resultCode == Activity.RESULT_OK && data != null) {
                    pendingResultCode = resultCode
                    pendingData = data
                    
                    // 오버레이 요청이 있었으면 바로 표시
                    if (overlayResultCallback != null) {
                        startOverlayService(resultCode, data)
                    } else {
                        resultCallback?.success("permission_granted")
                    }
                } else {
                    resultCallback?.error("PERMISSION_DENIED", "화면 캡처 권한이 거부되었습니다", null)
                    overlayResultCallback?.error("PERMISSION_DENIED", "화면 캡처 권한이 거부되었습니다", null)
                }
                resultCallback = null
                overlayResultCallback = null
            }
            REQUEST_OVERLAY_PERMISSION -> {
                val hasPermission = Settings.canDrawOverlays(this)
                if (hasPermission) {
                    // 오버레이 권한이 허용되었으므로 다시 오버레이 표시 시도
                    overlayResultCallback?.success("permission_granted")
                } else {
                    overlayResultCallback?.error("PERMISSION_DENIED", "오버레이 권한이 거부되었습니다", null)
                }
                overlayResultCallback = null
            }
        }
    }
}


