// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

// // onReceiveNotificationResponse called when app in foreground state
// // onBackgroundMessage called when app in background state
// // setupInteractedMessage called when app in terminate state

// class FirebaseCloudMessaging {
//   final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
//   FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

//   /// Create a [AndroidNotificationChannel] for heads up notifications
//   late AndroidNotificationChannel channel;

//   Future<void> setupInteractedMessage() async {
//     // Get any messages which caused the application to open from
//     // a terminated state.
//     RemoteMessage? initialMessage =
//         await FirebaseMessaging.instance.getInitialMessage();

//     if (initialMessage != null) {
//       _handleMessage(initialMessage);
//     }
//     // Also handle any interaction when the app is in the background via a
//     // Stream listener
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       _handleMessage(message);
//     });
//   }

//   //Handle Terminated messages here
//   void _handleMessage(RemoteMessage message) {
//     showFlutterNotification(message);
//     // handleRouteFromMessage(message.data);
//   }

//   void handleRouteFromMessage(Map<String, dynamic> message) {
//     switch (message['type']) {
//       case 'Home':
//         break;
//       case 'Category':
//         break;
//       default:
//         break;
//     }
//   }

//   getFirebaseNotification() async {
//     String fcmToken;
//     FirebaseMessaging.instance.getAPNSToken().then((APNStoken) {
//       print('here is APN token ---$APNStoken');
//     });
//     firebaseMessaging.getToken().then((value) async {
//       fcmToken = value.toString();
//       print('here is fcm token ---$fcmToken');
//     }).catchError((onError) {
//       print("Exception: $onError");
//     });

//     FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
//       // Note: This callback is fired at each app startup and whenever a new
//       // token is generated.
//     }).onError((err) {
//       // Error getting token.
//     });

//     //For Foreground Notifications
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       showFlutterNotification(message);
//     });
//   }

//   // Utility function to download and save a file to the device
//   Future<String> downloadAndSaveFile(String url, String fileName) async {
//     final Directory tempDir = await getTemporaryDirectory();
//     final String filePath = '${tempDir.path}/$fileName';
//     final http.Response response = await http.get(Uri.parse(url));
//     final File file = File(filePath);
//     await file.writeAsBytes(response.bodyBytes);
//     return filePath;
//   }

//   static Future<void> updateMessageTypes(
//     String channelId,
//     String newType,
//     String? senderId,
//   ) async {
//     log("IN UPDATE");

//     try {
//       final messagesRef = FirebaseFirestore.instance
//           .collection("groupChatChannel")
//           .doc(channelId)
//           .collection("messages");

//       final querySnapshot = await messagesRef.get();

//       for (var doc in querySnapshot.docs) {
//         final data = doc.data();
//         log("FOR ${data["type"] != "seen"} ");
//         if (data['senderId'] == senderId && data["type"] != "seen") {
//           log("IN IF ");
//           await doc.reference.update({"type": newType});
//         }
//       }
// //       final messagesRef = FirebaseFirestore.instance
// //           .collection("groupChatChannel")
// //           .doc(channelId)
// //           .collection("messages");

// // // Query only messages that are NOT sent by the current user
// //       final querySnapshot =
// //           await messagesRef.where("senderId", isNotEqualTo: senderId).get();

// //       for (var doc in querySnapshot.docs) {
// //         final data = doc.data();

// //         // Check if the message type is NOT "SEEN" before updating
// //         if (data["type"] != "seen") {
// //           await doc.reference.update({"type": newType});
// //           log("$newType , $channelId");
// //         }
// //         log("$newType , $channelId");
// //         log("${data["type"]} Message types updated successfully for messages not sent by $senderId.");
// //       }
//     } catch (e) {
//       log("Error updating message types: $e");
//     }
//   }

//   //Display Notifications
//   void showFlutterNotification(RemoteMessage message) async {
//     if (flutterLocalNotificationsPlugin == null) {
//       await setupFlutterNotifications();
//     }
//     updateMessageTypes(message.data['channelId'].toString(), "delivered",
//         message.data['senderId'].toString());

//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;

//     // if (notification != null && android != null) {
//     // Download the image
//     final String? imageUrl = message.data['image'];
//     final String bigPicturePath = imageUrl != null
//         ? await downloadAndSaveFile(imageUrl, 'big_picture')
//         : '';
//     log(' INTILIZATION :::${flutterLocalNotificationsPlugin == null}');
//     flutterLocalNotificationsPlugin?.show(
//       // 1,
//       DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       message.data['title'].toString(),
//       message.data['body'].toString(),
//       // notification.title,
//       // notification.body,
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           channel.id,
//           channel.name,
//           icon: '@mipmap/ic_launcher',
//           channelDescription: channel.description,
//           importance: Importance.max,
//           priority: Priority.high,
//           ticker: 'ticker',
//           actions: <AndroidNotificationAction>[
//             AndroidNotificationAction(
//               'ACTION_ID',
//               'Reply',
//               allowGeneratedReplies: true,
//               // showsUserInterface: true,
//               inputs: <AndroidNotificationActionInput>[
//                 AndroidNotificationActionInput(
//                   label: 'Type your reply...',
//                 ),
//               ],
//             ),
//           ],
//           // styleInformation: imageUrl != null
//           //     ? BigPictureStyleInformation(
//           //         FilePathAndroidBitmap(bigPicturePath),
//           //         largeIcon: FilePathAndroidBitmap(bigPicturePath),
//           //       )
//           //     : null,
//         ),
//         iOS: const DarwinNotificationDetails(),
//       ),
//       payload: message.data['type'],
//     );
//     // }
//   }

//   void handleReplyMessage(String? reply) {
//     if (reply != null && reply.isNotEmpty) {
//       log('User replied: $reply');
//       // Send reply to your backend or process it as needed
//       sendReplyToServer(reply);
//     }
//   }

//   Future<void> sendReplyToServer(String reply) async {
//     try {
//       final response = await http.post(
//         Uri.parse('YOUR_BACKEND_API_ENDPOINT'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'reply': reply}),
//       );
//       if (response.statusCode == 200) {
//         log('Reply sent successfully');
//       } else {
//         log('Failed to send reply: ${response.body}');
//       }
//     } catch (e) {
//       log('Error sending reply: $e');
//     }
//   }

//   //-- Foreground
//   void onReceiveNotificationResponse(NotificationResponse payload) async {
//     //Foreground redirection code
//     // Parse the payload to get the data
//     log('User Reply: ');
//     if (payload.actionId == 'reply_action') {
//       String? userReply = payload.input;
//       log('User Reply: $userReply');
//       handleReplyMessage(userReply);
//     }
//     // handleRouteFromMessage({"type": payload.payload});
//   }

//   Future<void> setupFlutterNotifications() async {
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     if (Platform.isIOS) {
//       await FirebaseMessaging.instance.requestPermission(
//           alert: true,
//           announcement: false,
//           badge: true,
//           carPlay: false,
//           criticalAlert: false,
//           sound: true,
//           provisional: false);
//     }
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     AndroidInitializationSettings initializationSettingsAndroid =
//         const AndroidInitializationSettings('@mipmap/ic_launcher');
//     // const AndroidInitializationSettings('ic_notification');

//     /// Note: permissions aren't requested here just to demonstrate that can be
//     /// done later
//     const DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       // onDidReceiveLocalNotification: (
//       //   int id,
//       //   String? title,
//       //   String? body,
//       //   String? payload,
//       // ) async {
//       //   print('here is payload ---> $payload');
//       // }
//     );

//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     await flutterLocalNotificationsPlugin?.initialize(initializationSettings,
//         onDidReceiveNotificationResponse: onReceiveNotificationResponse
//         // (NotificationResponse response) {
//         //   log("IN onDidReceiveNotificationResponse");
//         //   if (response.actionId == 'ACTION_ID') {
//         //     print('Action button clicked!');
//         //     // Perform your desired action
//         //   }
//         // },
//         );

//     channel = const AndroidNotificationChannel(
//       'high_importance_channel', // id
//       'High Importance Notifications', // title
//       description: 'This channel is used for important notifications.',
//       playSound: true,
//       importance: Importance.max,
//     );
//     await flutterLocalNotificationsPlugin
//         ?.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//   }
// }
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import '../../../features/data/api/firebase_remote_data_source.dart';
import '../../../features/data/models/group_entity.dart';
import '../../../features/presentation/cubit/chat/chat_cubit.dart';
import '../../../features/presentation/cubit/group/group_cubit.dart';
import '../../../injection_container.dart';
import '../hive/hive_model.dart';
import 'push_notification_service.dart';

/// A dedicated handler for notification actions that stores
/// notification-related data as instance variables instead of globals.
class NotificationHandler {
  // Singleton instance.
  static final NotificationHandler instance = NotificationHandler._internal();
  NotificationHandler._internal();

  String? _channelId;
  String? _senderId;
  String? _myId;
  String? _myName;
  String? _fcmToken;

  /// Update the handler with data from the incoming message.
  void updateFromMessageData(Map<String, String> data) {
    _channelId = data['channelId'];
    _senderId = data['senderId'];
    _myId = data['reciverId'];
    _myName = data['reciverName'];
  }

  /// Instance method that handles notification actions.
  Future<void> onActionReceivedMethod(ReceivedAction action) async {
    String? userReply;
    // Ensure FCM token is set for the sender.
    await _setFcm(_senderId ?? '');
    if (action.buttonKeyPressed == 'REPLY') {
      userReply = action.buttonKeyInput;
      // Optionally forward the reply if needed.
      // FirebaseCloudMessaging.instance.handleReplyMessage(userReply);
    }
    debugPrint("ACTION channelId: $_channelId");

    // Send the text message.
    serviceLocator<ChatCubit>().sendTextMessage(
      textMessageEntity: TextMessageModel(
        messageId: '',
        expiredAt: DateTime(2030),
        time: DateTime.now(),
        senderId: _myId ?? '',
        content: userReply,
        senderName: _myName ?? "",
        type: "sent",
        receiverName: '',
        recipientId: '',
      ),
      channelId: _channelId ?? "",
    );

    // Update the group with the last message.
    serviceLocator<GroupCubit>().updateGroup(
      groupEntity: GroupEntity(
        groupId: _channelId ?? '',
        lastMessage: userReply ?? '',
        creationTime: Timestamp.now(),
      ),
    );

    debugPrint("FCM Token: $_fcmToken");

    // Forward the notification to the selected driver.
    PushNotificationService.sendNotificationToSelectedDriver(
      _fcmToken ?? '',
      userReply ?? "",
      channelId: _channelId ?? "",
      senderId: _myId ?? '',
      reciverId: _senderId ?? '',
      reciverName: _myName ?? '',
    );
  }

  Future<void> _setFcm(String id) async {
    final fcmToken = await FirebaseRemoteDataSource.getFcmTokenByUid(id);
    debugPrint("FCM token fetched: $fcmToken");
    _fcmToken = fcmToken;
  }
}

/// Top-level function required by Awesome Notifications.
/// Delegates action handling to our NotificationHandler singleton.
Future<void> onActionReceived(ReceivedAction action) async {
  if (action.buttonKeyPressed == 'REPLY') {
    await NotificationHandler.instance.onActionReceivedMethod(action);
    log("ACTIONNIOOO");
  }
}

/// This class manages Firebase Messaging and Awesome Notifications.
class FirebaseCloudMessaging {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool notificationsInitialized = false;
  final NotificationHandler _notificationHandler = NotificationHandler.instance;

  /// Call early (e.g., in main()) to set up message handlers.
  Future<void> setupInteractedMessage() async {
    // Handle terminated state messages.
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    // Handle background/paused messages.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    // Display a notification via Awesome Notifications.
    showAwesomeNotification(message);
    // Optionally, handle additional routing here.
    // handleRouteFromMessage(message.data);
  }

  /// Update message types in Firestore (e.g., from "sent" to "delivered").
  static Future<void> updateMessageTypes(
    String channelId,
    String newType,
    String? senderId,
  ) async {
    debugPrint("Updating message types for channel: $channelId");
    try {
      final messagesRef = FirebaseFirestore.instance
          .collection("groupChatChannel")
          .doc(channelId)
          .collection("messages");

      final querySnapshot = await messagesRef.get();
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['senderId'] == senderId && data["type"] != "seen") {
          await doc.reference.update({"type": newType});
        }
      }
    } catch (e) {
      debugPrint("Error updating message types: $e");
    }
  }

  /// Set up Firebase notifications and listen for messages.
  Future<void> getFirebaseNotification() async {
    _firebaseMessaging.getAPNSToken().then((apnsToken) {
      debugPrint('APNS token: $apnsToken');
    });

    _firebaseMessaging.getToken().then((token) {
      debugPrint('FCM token: $token');
    }).catchError((onError) {
      debugPrint("Error fetching FCM token: $onError");
    });

    _firebaseMessaging.onTokenRefresh.listen((fcmToken) {
      // Handle token refresh if needed.
    }).onError((err) {});

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      showAwesomeNotification(message);
    });
  }

  /// Displays a notification using Awesome Notifications.
  Future<void> showAwesomeNotification(RemoteMessage message) async {
    if (!notificationsInitialized) {
      await setupAwesomeNotifications();
    }

    // Update our handler with data from the message.
    _notificationHandler.updateFromMessageData({
      'channelId': message.data['channelId']?.toString() ?? '',
      'senderId': message.data['senderId']?.toString() ?? '',
      'reciverId': message.data['reciverId']?.toString() ?? '',
      'reciverName': message.data['reciverName']?.toString() ?? '',
    });

    // Mark messages as delivered.
    updateMessageTypes(
      message.data['channelId']?.toString() ?? '',
      "delivered",
      message.data['senderId']?.toString(),
    );

    debugPrint("Displaying Awesome Notification");

    // Prepare notification content.
    String title = message.data['title']?.toString() ?? '';
    String body = message.data['body']?.toString() ?? '';
    String? imageUrl = message.data['image'];
    int notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    // Create the notification with an input action button.
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'high_importance_channel',
        title: title,
        body: body,
        bigPicture: imageUrl,
        notificationLayout: (imageUrl != null && imageUrl.isNotEmpty)
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
        payload: {'type': message.data['type'] ?? ''},
      ),
      actionButtons: [
        NotificationActionButton(
          actionType: ActionType.SilentAction,
          requireInputText: true,
          key: 'REPLY',
          label: 'Reply',
          autoDismissible: true,
        ),
      ],
    );
  }

  /// Handles the user's reply from the notification.
  void handleReplyMessage(String? reply) {
    if (reply != null && reply.isNotEmpty) {
      debugPrint('User replied: $reply');
      sendReplyToServer(reply);
    }
  }

  /// Sends the user's reply to your backend API.
  Future<void> sendReplyToServer(String reply) async {
    try {
      final response = await http.post(
        Uri.parse('YOUR_BACKEND_API_ENDPOINT'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reply': reply}),
      );
      if (response.statusCode == 200) {
        debugPrint('Reply sent successfully');
      } else {
        debugPrint('Failed to send reply: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending reply: $e');
    }
  }

  /// Initializes Awesome Notifications and registers the action listener.
  Future<void> setupAwesomeNotifications() async {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'high_importance_channel',
          channelName: 'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          defaultColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.Max,
          channelShowBadge: true,
        )
      ],
      debug: true,
    );

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // Register the top-level action listener.
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceived,
      onNotificationCreatedMethod: null,
      onNotificationDisplayedMethod: null,
      onDismissActionReceivedMethod: null,
    );

    notificationsInitialized = true;
  }
}
