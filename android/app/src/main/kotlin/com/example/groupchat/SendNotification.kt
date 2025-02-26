package com.example.groupchat  // Ensure your package name is correct

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.RemoteInput
import com.example.groupchat.MyReplyReceiver  // Ensure this is correctly imported

fun sendNotification(context: Context) {
    val replyLabel = "Enter your reply here"
    val remoteInput = RemoteInput.Builder("KEY_TEXT_REPLY")
        .setLabel(replyLabel)
        .build()

    val replyIntent = Intent(context, MyReplyReceiver::class.java)
    replyIntent.putExtra("notificationId", 101)  // Ensures notification is dismissed after reply

    val replyPendingIntent = PendingIntent.getBroadcast(
        context, 0, replyIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    val replyAction = NotificationCompat.Action.Builder(
        android.R.drawable.ic_menu_send, "Reply", replyPendingIntent
    ).addRemoteInput(remoteInput).build()

    val channelId = "reply_channel"
    val channel = NotificationChannel(channelId, "Reply Notifications", NotificationManager.IMPORTANCE_HIGH)
    val manager = context.getSystemService(NotificationManager::class.java)
    manager.createNotificationChannel(channel)

    val notification = NotificationCompat.Builder(context, channelId)
        .setSmallIcon(android.R.drawable.ic_dialog_info)
        .setContentTitle("New Message")
        .setContentText("Reply to this message")
        .addAction(replyAction)
        .setAutoCancel(true)
        .build()

    NotificationManagerCompat.from(context).notify(101, notification)
}
