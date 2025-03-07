import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart' show Workmanager;
import '../../../features/data/api/firebase_remote_data_source.dart';
import '../../../features/data/models/group_entity.dart';
import '../../../features/data/repositories/create_group_repository.dart';
import '../../../features/data/repositories/get_all_group_repository.dart';
import '../../../features/data/repositories/get_messages_repository.dart';
import '../../../features/data/repositories/join_group_repository.dart';
import '../../../features/data/repositories/send_text_message_repository.dart';
import '../../../features/data/repositories/update_group_repository.dart';
import '../../../features/data/services/firebase_services.dart';
import '../../../features/presentation/cubit/chat/chat_cubit.dart';
import '../../../features/presentation/cubit/group/group_cubit.dart';
import '../../../firebase_options.dart';
import '../../../injection_container.dart';
import '../../../main.dart';
import '../hive/hive_model.dart';
import "package:firebase_core/firebase_core.dart";
import 'package:shared_preferences/shared_preferences.dart';

import 'push_notification_service.dart';

/// Top-level function required by Awesome Notifications.
/// Delegates action handling to our NotificationHandler singleton.
@pragma('vm:entry-point')
Future<void> onActionReceived(ReceivedAction action) async {
  if (action.buttonKeyPressed == 'REPLY') {
    debugPrint(
        "onActionReceived - SenderId: ${NotificationHandler.instance.senderId}");
    await NotificationHandler.instance.onActionReceivedMethod(action);
    log("Notification action processed");
    // Explicitly dismiss the notification.
  }
}

/// A dedicated handler for notification actions.
class NotificationHandler {
  // Singleton instance.
  static final NotificationHandler instance = NotificationHandler._internal();
  NotificationHandler._internal();

  bool actionProcessed = false;

  // Instance variables loaded from SharedPreferences or the message.
  String? channelId;
  String? senderId;
  String? myId;
  String? myName;
  String? fcmToken;

  /// Updates handler variables from the incoming message data.
  void updateFromMessageData(Map<String, String> data) {
    channelId = data['channelId'];
    senderId = data['senderId'];
    myId = data['reciverId'];
    myName = data['reciverName'];
    debugPrint("Updated channelId: $channelId");
  }

  /// Handles the action received from the notification.
  Future<void> onActionReceivedMethod(ReceivedAction action) async {
    // Load stored values.
    final prefs = await SharedPreferences.getInstance();
    await _loadPreferences(prefs);

    // Ensure Flutter and Firebase are initialized.
    WidgetsFlutterBinding.ensureInitialized();
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Prevent duplicate processing.
    if (actionProcessed) return;
    actionProcessed = true;

    // Initialize required dependencies if not already registered.
    await _initializeDependencies();

    if (action.buttonKeyPressed == 'REPLY') {
      final userReply = action.buttonKeyInput;
      debugPrint(
          "Notification action - channelId: $channelId, UserReply: $userReply");

      // Ensure FCM token is set for the sender.
      await _setFcm(senderId ?? '');

      // Update the group with the last message.
      serviceLocator<GroupCubit>().updateGroup(
        groupEntity: GroupEntity(
          groupId: channelId ?? '',
          lastMessage: userReply ?? '',
          creationTime: Timestamp.now(),
        ),
      );

      // Send the text message.
      serviceLocator<ChatCubit>().sendTextMessage(
        textMessageEntity: TextMessageModel(
          messageId: '',
          expiredAt: DateTime(2030),
          time: DateTime.now(),
          senderId: myId ?? '',
          content: userReply,
          senderName: myName ?? "",
          type: "sent",
          receiverName: '',
          recipientId: '',
        ),
        channelId: channelId ?? "",
      );

      debugPrint("FCM Token: $fcmToken");
      // final lifecycleState = WidgetsBinding.instance.lifecycleState;
      log("Global isForeground: ${lifecycleObserver.isForeground}");
      if (!lifecycleObserver.isForeground) {
        log("App is not in foreground; scheduling background task.");
        Workmanager().registerOneOffTask(
          "sendNotificationTask",
          "sendNotification",
          inputData: {
            'fcmToken': fcmToken,
            'userReply': userReply,
            'channelId': channelId,
            'senderId': myId,
            'receiverId': senderId,
            'receiverName': myName,
          },
        );
      } else {
        await PushNotificationService.sendNotificationToSelectedDriver(
          fcmToken ?? '',
          userReply,
          channelId: channelId ?? '',
          senderId: myId ?? '',
          reciverId: senderId ?? '',
          reciverName: myName ?? '',
        );
        log("App is in foreground; background task not scheduled.");
      }
    }
    await AwesomeNotifications().dismiss(action.id!);
  }

  /// Loads notification-related data from SharedPreferences.
  Future<void> _loadPreferences(SharedPreferences prefs) async {
    channelId = prefs.getString('channelId');
    senderId = prefs.getString('senderId');
    myId = prefs.getString('reciverId');
    myName = prefs.getString('reciverName');
    fcmToken = prefs.getString('fcm');
  }

  /// Initializes dependencies via GetIt if they are not already registered.
  Future<void> _initializeDependencies() async {
    if (!GetIt.I.isRegistered<FirebaseServices>()) {
      serviceLocator.registerLazySingleton<FirebaseServices>(
          () => FirebaseServices(remoteDataSource: serviceLocator()));
    }
    if (!GetIt.I.isRegistered<GetMessageRepository>()) {
      serviceLocator.registerLazySingleton<GetMessageRepository>(
          () => GetMessageRepository(repository: serviceLocator()));
    }
    if (!GetIt.I.isRegistered<SendTextMessageRepository>()) {
      serviceLocator.registerLazySingleton<SendTextMessageRepository>(
          () => SendTextMessageRepository(repository: serviceLocator()));
    }
    if (!GetIt.I.isRegistered<FirebaseRemoteDataSource>()) {
      final fireStore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;
      final googleSignIn = GoogleSignIn();
      serviceLocator.registerLazySingleton<FirebaseRemoteDataSource>(
          () => FirebaseRemoteDataSource(fireStore, auth, googleSignIn));
    }
    if (!GetIt.I.isRegistered<ChatCubit>()) {
      log("ChatCubit not registered; registering now.");
      serviceLocator.registerLazySingleton<ChatCubit>(() => ChatCubit(
            getMessageRepository: serviceLocator(),
            sendTextMessageRepository: serviceLocator(),
          ));
    }
    if (!GetIt.I.isRegistered<GetCreateGroupRepository>()) {
      serviceLocator.registerLazySingleton<GetCreateGroupRepository>(
          () => GetCreateGroupRepository(repository: serviceLocator()));
    }
    if (!GetIt.I.isRegistered<GetAllGroupsRepository>()) {
      serviceLocator.registerLazySingleton<GetAllGroupsRepository>(
          () => GetAllGroupsRepository(repository: serviceLocator()));
    }
    if (!GetIt.I.isRegistered<JoinGroupRepository>()) {
      serviceLocator.registerLazySingleton<JoinGroupRepository>(
          () => JoinGroupRepository(repository: serviceLocator()));
    }
    if (!GetIt.I.isRegistered<UpdateGroupRepository>()) {
      serviceLocator.registerLazySingleton<UpdateGroupRepository>(
          () => UpdateGroupRepository(repository: serviceLocator()));
    }
    if (!GetIt.I.isRegistered<GroupCubit>()) {
      serviceLocator.registerFactory<GroupCubit>(() => GroupCubit(
            getAllGroupsRepository: serviceLocator(),
            getCreateGroupRepository: serviceLocator(),
            joinGroupRepository: serviceLocator(),
            groupRepository: serviceLocator(),
          ));
    }
  }

  /// Sets the FCM token by querying using the sender's id.
  Future<void> _setFcm(String id) async {
    fcmToken = await FirebaseRemoteDataSource.getFcmTokenByUid(id);
    debugPrint("FCM token fetched: $fcmToken");
  }
}

/// Manages Firebase Messaging and Awesome Notifications.
class FirebaseCloudMessaging {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool notificationsInitialized = false;
  final NotificationHandler _notificationHandler = NotificationHandler.instance;

  /// Set up message handlers (for terminated, background, or foreground states).
  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    log("Handling incoming message");
    showAwesomeNotification(message);
  }

  /// Updates message types in Firestore (e.g., marking messages as "delivered").
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

  /// Sets up Firebase Messaging notifications.
  Future<void> getFirebaseNotification() async {
    _firebaseMessaging.getAPNSToken().then(
          (apnsToken) => debugPrint('APNS token: $apnsToken'),
        );
    _firebaseMessaging
        .getToken()
        .then(
          (token) => debugPrint('FCM token: $token'),
        )
        .catchError((onError) {
      debugPrint("Error fetching FCM token: $onError");
    });

    _firebaseMessaging.onTokenRefresh.listen((fcmToken) {
      // Handle token refresh if needed.
    }).onError((err) {});

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("Received message in foreground");
      showAwesomeNotification(message);
    });
  }

  /// Saves notification data to SharedPreferences.
  Future<void> saveNotificationData(Map<String, String> messageData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('channelId', messageData['channelId'] ?? '');
    await prefs.setString('senderId', messageData['senderId'] ?? '');
    await prefs.setString('reciverId', messageData['reciverId'] ?? '');
    await prefs.setString('reciverName', messageData['reciverName'] ?? '');
  }

  /// Retrieves notification data from SharedPreferences.
  static Future<Map<String, String>> getNotificationData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'channelId': prefs.getString('channelId') ?? '',
      'senderId': prefs.getString('senderId') ?? '',
      'reciverId': prefs.getString('reciverId') ?? '',
      'reciverName': prefs.getString('reciverName') ?? '',
    };
  }

  /// Displays a notification using Awesome Notifications.
  Future<void> showAwesomeNotification(RemoteMessage message) async {
    if (!notificationsInitialized) {
      await setupAwesomeNotifications();
    }
    debugPrint(
        "Preparing to display Awesome Notification with channelId: ${message.data['channelId']}");

    // Update the notification handler with new data.
    _notificationHandler.updateFromMessageData({
      'channelId': message.data['channelId']?.toString() ?? '',
      'senderId': message.data['senderId']?.toString() ?? '',
      'reciverId': message.data['reciverId']?.toString() ?? '',
      'reciverName': message.data['reciverName']?.toString() ?? '',
    });
    // Persist the data for later use.
    await saveNotificationData({
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
    _notificationHandler.actionProcessed = false;

    // Build notification content.
    final title = message.data['title']?.toString() ?? '';
    final body = message.data['body']?.toString() ?? '';
    final imageUrl = message.data['image'];
    final notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        actionType: ActionType.SilentAction,
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

  /// Initializes Awesome Notifications and registers listeners.
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
          soundSource: null,
        )
      ],
      debug: false,
    );

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    if (!notificationsInitialized) {
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceived,
        onNotificationCreatedMethod: null,
        onNotificationDisplayedMethod: null,
        onDismissActionReceivedMethod: null,
      );
      notificationsInitialized = true;
    }
  }
}
