import 'dart:developer';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// onReceiveNotificationResponse called when app in foreground state
// onBackgroundMessage called when app in background state
// setupInteractedMessage called when app in terminate state

class FirebaseCloudMessaging {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }

  //Handle Terminated messages here
  void _handleMessage(RemoteMessage message) {
    showFlutterNotification(message);
    // handleRouteFromMessage(message.data);
  }

  void handleRouteFromMessage(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'Home':
        break;
      case 'Category':
        break;
      default:
        break;
    }
  }

  getFirebaseNotification() async {
    String fcmToken;
    FirebaseMessaging.instance.getAPNSToken().then((APNStoken) {
      print('here is APN token ---$APNStoken');
    });
    firebaseMessaging.getToken().then((value) async {
      fcmToken = value.toString();
      print('here is fcm token ---$fcmToken');
    }).catchError((onError) {
      print("Exception: $onError");
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }).onError((err) {
      // Error getting token.
    });

    //For Foreground Notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      showFlutterNotification(message);
    });
  }

  // Utility function to download and save a file to the device
  Future<String> downloadAndSaveFile(String url, String fileName) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  //Display Notifications
  void showFlutterNotification(RemoteMessage message) async {
    if (flutterLocalNotificationsPlugin == null) {
      await setupFlutterNotifications();
    }
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      // Download the image
      final String? imageUrl = message.data['image'];
      final String bigPicturePath = imageUrl != null
          ? await downloadAndSaveFile(imageUrl, 'big_picture')
          : '';
      log(' INTILIZATION :::${flutterLocalNotificationsPlugin == null}');
      flutterLocalNotificationsPlugin?.show(
        // 1,
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: '@mipmap/ic_launcher',
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction(
                'reply_action',
                'Reply',
                inputs: <AndroidNotificationActionInput>[
                  AndroidNotificationActionInput(label: 'Type your reply...')
                ],
              ),
            ],
            // styleInformation: imageUrl != null
            //     ? BigPictureStyleInformation(
            //         FilePathAndroidBitmap(bigPicturePath),
            //         largeIcon: FilePathAndroidBitmap(bigPicturePath),
            //       )
            //     : null,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data['type'],
      );
    }
  }

  //-- Foreground
  void onReceiveNotificationResponse(NotificationResponse payload) async {
    //Foreground redirection code
    // Parse the payload to get the data
    handleRouteFromMessage({"type": payload.payload});
  }
  Future<void> setupFlutterNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          sound: true,
          provisional: false);
    }
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    // const AndroidInitializationSettings('ic_notification');

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: (
      //   int id,
      //   String? title,
      //   String? body,
      //   String? payload,
      // ) async {
      //   print('here is payload ---> $payload');
      // }
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin?.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onReceiveNotificationResponse,
    );

    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      playSound: true,
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}
