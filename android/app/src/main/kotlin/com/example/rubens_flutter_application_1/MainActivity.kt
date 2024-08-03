package com.example.rubens_flutter_application_1

import io.flutter.embedding.android.FlutterActivity
import android.content.Context
import android.media.AudioManager
import android.view.KeyEvent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.timer/stopAudio"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine){
        super.configureFlutterEngine(flutterEngine)
    
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "stopAudio"){
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                if ( audioManager != null){
                    audioManager.dispatchMediaKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_MEDIA_PAUSE))
                    audioManager.dispatchMediaKeyEvent(KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_MEDIA_PAUSE))
                    result.success(null)
                } else {
                    result.error("UNAVAILABLE", "AudioManager not available", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
