package time2sleep

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import java.lang.InterruptedException
import java.lang.Thread

class TimeService: Service() {
    private var wakeLock: PowerManager.WakeLock? = null
    private var startTimeInMillis: Long = 0
    private var remainingTimeInMillis: Long = 0
    private var timerRunning = false

    override fun onCreate(){
        super.onCreate()
        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "time2sleep::TimerWakeLock")
        wakeLock?.acquire()
    }

    override fun onStartCommand(intent: Intent?, flag: Int, startId: Int): Int{
        if(intent != null){
            startTimeInMillis = intent.getLongExtra("startTimeMillis", 0)
            remainingTimeInMillis = startTimeInMillis
            startTimer()
        }
        return START_STICKY
    }

    private fun startTimer(){
        timerRunning = true
        val timerThread = Thread{
            while (timerRunning && remainingTimeInMillis > 0){
                try {
                    Thread.sleep(1000)
                    remainingTimeInMillis -= 1000
                    Log.d("TimeService", "Remaining time : $remainingTimeInMillis")
                } catch (e: InterruptedException){
                    e.printStackTrace()
                }
            }
            if(remainingTimeInMillis <= 0){
                timerRunning = false
                stopSelf()

            }
        }
        timerThread.start()
    }

    override fun onDestroy(){
        super.onDestroy()
        timerRunning = false
        wakeLock?.release()
    }
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
