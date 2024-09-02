class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.timer/stopAudio"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine){
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "stopAudio" -> {
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
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
                }
                "startTimeService" -> {
                    val startTimeInMillis = call.argument<Long>("startTimeInMillis")!!
                    val intent = Intent(this, TimeService::class.java)
                    intent.putExtra("startTimeInMillis", startTimeInMillis)  // Ensure this is Long
                    startService(intent)
                    result.success(null)
                }
                "stopTimeService" -> {
                    val intent = Intent(this, TimeService::class.java)
                    stopService(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
