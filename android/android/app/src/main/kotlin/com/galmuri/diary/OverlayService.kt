package com.galmuri.diary

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
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

import android.content.pm.ServiceInfo

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
    private var overlayParams: WindowManager.LayoutParams? = null
    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f
    private var imageReaderHandler: android.os.Handler? = null
    private var imageReaderThread: android.os.HandlerThread? = null

    companion object {
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "overlay_service_channel"
        private const val PREFS_NAME = "overlay_prefs"
        private const val PREF_OVERLAY_X = "overlay_x"
        private const val PREF_OVERLAY_Y = "overlay_y"
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
        
        // ImageReader용 백그라운드 스레드 생성
        imageReaderThread = android.os.HandlerThread("ImageReaderThread").apply {
            start()
        }
        imageReaderHandler = android.os.Handler(imageReaderThread!!.looper)
        
        createNotificationChannel()
        
        val notification = createNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
                } else {
                    0
                }
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
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

        try {
            // MediaProjection 설정
            if (resultCode != 0 && resultData != null) {
                mediaProjection = mediaProjectionManager?.getMediaProjection(resultCode, resultData)
                android.util.Log.d("OverlayService", "MediaProjection initialized successfully")
            } else {
                android.util.Log.e("OverlayService", "Invalid resultCode or resultData")
                stopSelf()
                return
            }

            // 저장된 위치 불러오기
            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val savedX = prefs.getInt(PREF_OVERLAY_X, -1)
            val savedY = prefs.getInt(PREF_OVERLAY_Y, -1)

            // 오버레이 버튼 생성
            val button = Button(this).apply {
                text = "화면 캡처"
                setBackgroundColor(Color.parseColor("#FF0000"))
                setTextColor(Color.WHITE)
                textSize = 14f
                setPadding(32, 16, 32, 16)
                
                // 버튼을 터치 가능하게 설정
                isClickable = true
                isFocusable = false
                
                var isDragging = false
                var downTime = 0L
                
                android.util.Log.d("OverlayService", "빨간 버튼 생성 완료")
                
                // 드래그 가능하도록 터치 리스너 설정
                setOnTouchListener { view, event ->
                    when (event.action) {
                        MotionEvent.ACTION_DOWN -> {
                            android.util.Log.d("OverlayService", "버튼 ACTION_DOWN")
                            downTime = System.currentTimeMillis()
                            isDragging = false
                            overlayParams?.let { params ->
                                initialX = params.x
                                initialY = params.y
                            } ?: run {
                                initialX = 0
                                initialY = 0
                            }
                            initialTouchX = event.rawX
                            initialTouchY = event.rawY
                            true
                        }
                        MotionEvent.ACTION_MOVE -> {
                            val deltaX = (event.rawX - initialTouchX).toInt()
                            val deltaY = (event.rawY - initialTouchY).toInt()
                            val moveDistance = Math.sqrt(
                                Math.pow(deltaX.toDouble(), 2.0) +
                                Math.pow(deltaY.toDouble(), 2.0)
                            )
                            
                            // 10픽셀 이상 이동하면 드래그로 간주
                            if (moveDistance > 10) {
                                isDragging = true
                                overlayParams?.let { params ->
                                    params.x = initialX + deltaX
                                    params.y = initialY + deltaY
                                    
                                    // 화면 경계 체크
                                    params.x = params.x.coerceIn(0, screenWidth - view.width)
                                    params.y = params.y.coerceIn(0, screenHeight - view.height)
                                    
                                    windowManager?.updateViewLayout(overlayView, params)
                                }
                            }
                            true
                        }
                        MotionEvent.ACTION_UP -> {
                            android.util.Log.d("OverlayService", "버튼 ACTION_UP (isDragging=$isDragging)")
                            val upTime = System.currentTimeMillis()
                            val timeDiff = upTime - downTime
                            
                            // 위치 저장
                            overlayParams?.let { params ->
                                prefs.edit()
                                    .putInt(PREF_OVERLAY_X, params.x)
                                    .putInt(PREF_OVERLAY_Y, params.y)
                                    .apply()
                            }
                            
                            // 드래그가 아니고 짧은 시간(300ms 이하)이면 클릭으로 간주
                            if (!isDragging && timeDiff < 300) {
                                android.util.Log.d("OverlayService", "클릭 감지! captureScreen() 호출")
                                captureScreen()
                            } else {
                                android.util.Log.d("OverlayService", "드래그로 판단됨 (isDragging=$isDragging, timeDiff=${timeDiff}ms)")
                            }
                            
                            view.performClick()
                            true
                        }
                        else -> false
                    }
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
                // FLAG_NOT_TOUCH_MODAL을 추가하여 버튼이 터치를 받을 수 있게 함
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or 
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.TOP or Gravity.START
                // 저장된 위치가 있으면 사용, 없으면 기본 위치
                if (savedX >= 0 && savedY >= 0) {
                    x = savedX
                    y = savedY
                } else {
                    x = (screenWidth / 2) - 100 // 중앙에서 약간 왼쪽
                    y = 100
                }
            }
            
            android.util.Log.d("OverlayService", "오버레이 레이아웃 설정 완료: x=${layoutParams.x}, y=${layoutParams.y}")

            overlayParams = layoutParams
            overlayView = button
            
            try {
                windowManager?.addView(overlayView, layoutParams)
                android.util.Log.d("OverlayService", "Overlay button displayed successfully")
                
                // 버튼이 실제로 터치 가능한지 확인
                button.isClickable = true
                button.isFocusable = false
                android.util.Log.d("OverlayService", "버튼 클릭 가능 설정 완료")
            } catch (e: Exception) {
                android.util.Log.e("OverlayService", "Failed to add overlay view: ${e.message}", e)
                throw e
            }
        } catch (e: Exception) {
            android.util.Log.e("OverlayService", "Failed to show overlay button: ${e.message}", e)
            e.printStackTrace()
            stopSelf() // 에러 발생 시 서비스 종료
        }
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
            android.util.Log.e("OverlayService", "MediaProjection is null, cannot capture screen")
            return
        }

        android.util.Log.d("OverlayService", "Starting screen capture")

        // 기존 리소스 정리 (중복 호출 방지)
        virtualDisplay?.release()
        imageReader?.close()
        
        imageReader = ImageReader.newInstance(screenWidth, screenHeight, PixelFormat.RGBA_8888, 2)
        
        try {
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
            android.util.Log.d("OverlayService", "VirtualDisplay created successfully")
        } catch (e: Exception) {
            android.util.Log.e("OverlayService", "Failed to create VirtualDisplay: ${e.message}", e)
            e.printStackTrace()
            hideOverlayButton()
            return
        }

        // ImageReader 리스너를 백그라운드 스레드에서 실행
        imageReader?.setOnImageAvailableListener({ reader ->
            android.util.Log.d("OverlayService", "ImageReader onImageAvailable 콜백 호출됨")
            val image = reader.acquireLatestImage()
            android.util.Log.d("OverlayService", "Image acquired: ${image != null}")
            if (image != null) {
                try {
                    android.util.Log.d("OverlayService", "이미지 변환 시작 (width=${image.width}, height=${image.height})")
                    val bitmap = imageToBitmap(image)
                    android.util.Log.d("OverlayService", "Bitmap 생성 완료")
                    val byteArray = bitmapToByteArray(bitmap)
                    android.util.Log.d("OverlayService", "ByteArray 변환 완료 (size=${byteArray.size})")
                    
                    // MainActivity에 캡처 결과 전달
                    android.util.Log.d("OverlayService", "캡처 완료, MainActivity로 전달 (bytes=${byteArray.size})")
                    val mainActivity = MainActivity.getInstance()
                    if (mainActivity != null) {
                        android.util.Log.d("OverlayService", "MainActivity 인스턴스 발견, onScreenCaptured 호출")
                        mainActivity.onScreenCaptured(byteArray)
                    } else {
                        android.util.Log.e("OverlayService", "MainActivity 인스턴스가 null입니다!")
                    }
                    
                    // 정리
                    image.close()
                    virtualDisplay?.release()
                    virtualDisplay = null
                    imageReader?.close()
                    imageReader = null
                    mediaProjection?.stop()
                    
                    // 오버레이 숨기기
                    hideOverlayButton()
                    
                    // 앱을 포그라운드로 가져오기
                    val intent = packageManager.getLaunchIntentForPackage(packageName)
                    intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    startActivity(intent)
                } catch (e: Exception) {
                    // 에러 발생 시 리소스 정리
                    android.util.Log.e("OverlayService", "이미지 처리 중 오류: ${e.message}", e)
                    image.close()
                    virtualDisplay?.release()
                    virtualDisplay = null
                    imageReader?.close()
                    imageReader = null
                    hideOverlayButton()
                }
            } else {
                android.util.Log.e("OverlayService", "acquireLatestImage()가 null 반환")
            }
        }, imageReaderHandler)
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
        // 모든 리소스 정리
        virtualDisplay?.release()
        virtualDisplay = null
        imageReader?.close()
        imageReader = null
        mediaProjection?.stop()
        mediaProjection = null
        hideOverlayButton()
        
        // 백그라운드 스레드 정리
        imageReaderThread?.quitSafely()
        imageReaderThread = null
        imageReaderHandler = null
    }
}

