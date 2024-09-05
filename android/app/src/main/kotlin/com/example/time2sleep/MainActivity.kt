package time2sleep

import io.flutter.embedding.android.FlutterActivity
import android.os.PowerManager
import android.content.Context
import android.media.AudioManager
import android.view.KeyEvent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.timer/stopAudio"

    private lateinit var powerManager: PowerManager
    private lateinit var wakeLock: PowerManager.WakeLock

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "TimerApp:WakeLock")

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "stopAudio" -> {
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    if (audioManager != null) {
                        audioManager.dispatchMediaKeyEvent(
                            KeyEvent(
                                KeyEvent.ACTION_DOWN,
                                KeyEvent.KEYCODE_MEDIA_PAUSE
                            )
                        )
                        audioManager.dispatchMediaKeyEvent(
                            KeyEvent(
                                KeyEvent.ACTION_UP,
                                KeyEvent.KEYCODE_MEDIA_PAUSE
                            )
                        )
                        result.success(null)
                    } else {
                        result.error("UNAVAILABLE", "AudioManager not available", null)
                    }
                }

                "stayAwake" -> {
                    wakeLock.acquire()
                    result.success(null)
                }
                "releaseWakeLock" -> {
                    if(wakeLock.isHeld){
                        wakeLock.release()
                    }
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
