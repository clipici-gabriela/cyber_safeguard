package com.example.cyber_safeguard

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.SetOptions
import com.google.firebase.FirebaseApp
import java.util.*

class AppUsageService : Service() {

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        FirebaseApp.initializeApp(this)  // Initialize Firebase

        createNotificationChannel()
        val notification = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("App Usage Monitoring")
            .setContentText("Monitoring app usage in the background")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .build()
        startForeground(1, notification)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) {
            Log.e("AppUsageService", "Received null Intent in onStartCommand")
            return START_NOT_STICKY
        }

        Thread {
            while (true) {
                logCurrentAppUsage()
                try {
                    Thread.sleep(30000) // Sleep for 30 seconds
                } catch (e: InterruptedException) {
                    e.printStackTrace()
                }
            }
        }.start()
        return START_STICKY
    }

    private fun logCurrentAppUsage() {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()
        val appList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            time - 1000 * 60,
            time
        )
        if (appList != null && appList.isNotEmpty()) {
            val sortedMap = TreeMap<Long, UsageStats>()
            for (usageStats in appList) {
                sortedMap[usageStats.lastTimeUsed] = usageStats
            }
            if (sortedMap.isNotEmpty()) {
                val currentApp = sortedMap[sortedMap.lastKey()]!!.packageName
                Log.d("AppUsageService", "Current App in foreground: $currentApp")
                
                // Fetch the app details
                val usageStats = sortedMap[sortedMap.lastKey()]
                val screenTime = usageStats?.totalTimeInForeground ?: 0
                val lastTimeUsed = Date(usageStats?.lastTimeUsed ?: 0)

                Log.d("AppUsageService", "Screen Time: $screenTime")
                Log.d("AppUsageService", "Last Time Used: $lastTimeUsed")

                // Send the current app info to Firebase
                updateFirebase(currentApp, screenTime, lastTimeUsed)
            } else {
                Log.d("AppUsageService", "No foreground app found")
            }
        } else {
            Log.d("AppUsageService", "No usage stats available")
        }
    }

    private fun updateFirebase(packageName: String, screenTime: Long, lastTimeUsed: Date) {
        val firestore = FirebaseFirestore.getInstance()
        val currentUser = FirebaseAuth.getInstance().currentUser
        currentUser?.let { user ->
            val appDocRef = firestore.collection("Apps")
                .document(user.uid)
                .collection("UserApps")
                .document(packageName)

            appDocRef.get().addOnSuccessListener { document ->
                val currentScreenTime = document.getLong("screenTime") ?: 0
                val newScreenTime = currentScreenTime + screenTime / 1000 / 60 // Convert milliseconds to minutes

                Log.d("AppUsageService", "Current Screen Time in Firebase: $currentScreenTime")
                Log.d("AppUsageService", "New Screen Time to Update: $newScreenTime")

                val appData = hashMapOf(
                    "packageName" to packageName,
                    "lastTimeUsed" to lastTimeUsed,
                    "screenTime" to newScreenTime,
                    "name" to packageName // Replace with actual app name if you have it
                )

                appDocRef.set(appData, SetOptions.merge())
                    .addOnSuccessListener {
                        Log.d("AppUsageService", "App usage updated in Firebase for $packageName")
                    }
                    .addOnFailureListener { e ->
                        Log.w("AppUsageService", "Error updating app usage in Firebase", e)
                    }
            }.addOnFailureListener { e ->
                Log.w("AppUsageService", "Error fetching app document from Firebase", e)
            }
        } ?: run {
            Log.w("AppUsageService", "No current user authenticated")
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "App Usage Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
    }

    companion object {
        private const val CHANNEL_ID = "AppUsageChannel"
    }
}
