package com.example.groupchat  // Make sure this matches your app package name

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.core.app.RemoteInput
import io.flutter.plugin.common.MethodChannel

class MyReplyReceiver : BroadcastReceiver() {
    companion object {
        var methodChannel: MethodChannel? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        val remoteInput: Bundle? = RemoteInput.getResultsFromIntent(intent)
        if (remoteInput != null) {
            val replyText = remoteInput.getCharSequence("KEY_TEXT_REPLY")?.toString()
            Log.d("NotificationReply", "User replied: $replyText")

            // Send reply to Flutter via MethodChannel
            methodChannel?.invokeMethod("onNotificationReply", replyText)

            // Dismiss the notification
            val notificationId = intent.getIntExtra("notificationId", -1)
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (notificationId != -1) {
                notificationManager.cancel(notificationId)
            }
        }
    }
}
