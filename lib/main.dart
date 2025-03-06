import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:group_chat/core/constants/app_const.dart';
import 'package:group_chat/features/presentation/cubit/chat/chat_cubit.dart';
import 'package:group_chat/features/presentation/cubit/user/user_cubit.dart';
import 'package:group_chat/features/presentation/pages/login_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workmanager/workmanager.dart';
import 'core/services/network/bloc/network_bloc.dart';
import 'core/services/notification/awesome_notification_service.dart';
import 'core/services/notification/push_notification_service.dart';
import 'features/presentation/cubit/auth/auth_cubit.dart';
import 'features/presentation/cubit/credential/credential_cubit.dart';
import 'features/presentation/cubit/group/group_cubit.dart';
import 'features/presentation/pages/home_page.dart';
import 'firebase_options.dart';
import 'core/routes/on_generate_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'injection_container.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("IN firebaseMessagingBackgroundHandler");
  // await init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!GetIt.I.isRegistered<FirebaseCloudMessaging>()) {
    serviceLocator.registerLazySingleton<FirebaseCloudMessaging>(
        () => FirebaseCloudMessaging());
  }

  serviceLocator<FirebaseCloudMessaging>().showAwesomeNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await init();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true, //count of notification
    carPlay: true,
    criticalAlert: true,
    sound: true,
    provisional: false,
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  const MethodChannel platform =
      MethodChannel('com.example.groupchat/notifications');

  platform.setMethodCallHandler((MethodCall call) async {
    if (call.method == "onNotificationReply") {
      String reply = call.arguments;
      print("User replied: $reply");
    }

  });
  await Workmanager().initialize(
    callbackDispatcher, // Background callback
    isInDebugMode: true, // Remove this in production
  );
  runApp(MyApp());
}
@pragma('vm:entry-point') 
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Extract data from inputData
    String? fcmToken = inputData?['fcmToken'];
    String? userReply = inputData?['userReply'];
    String? channelId = inputData?['channelId'];
    String? senderId = inputData?['senderId'];
    String? receiverId = inputData?['receiverId'];
    String? receiverName = inputData?['receiverName'];

    // Ensure dependencies are initialized (if using Firebase, GetIt, etc.)
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      // Call the notification service
      await PushNotificationService.sendNotificationToSelectedDriver(
        fcmToken ?? '',
        userReply ?? '',
        channelId: channelId ?? '',
        senderId: senderId ?? '',
        reciverId: receiverId ?? '',
        reciverName: receiverName ?? '',
      );

      return Future.value(true);
    } catch (e) {
      debugPrint("Error in WorkManager: $e");
      return Future.value(false);
    }
  });
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<NetworkBloc>(
            create: (_) => NetworkBloc()..add(NetworkObserve()),
          ),
          BlocProvider<AuthCubit>(
            create: (_) => serviceLocator<AuthCubit>()..appStarted(),
          ),
          BlocProvider<CredentialCubit>(
            create: (_) => serviceLocator<CredentialCubit>(),
          ),
          BlocProvider<UserCubit>(
            create: (_) => serviceLocator<UserCubit>()..getUsers(),
          ),
          BlocProvider<GroupCubit>(
            create: (_) => serviceLocator<GroupCubit>()..getGroups(''),
          ),
          BlocProvider<ChatCubit>(
            create: (_) => serviceLocator<ChatCubit>(),
          ),
        ],
        child: ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, child) {
              return MaterialApp(
                title: AppConst.appName,
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primarySwatch: Colors.green,
                ),
                initialRoute: '/',
                onGenerateRoute: OnGenerateRoute.route,
                routes: {
                  "/": (context) {
                    return BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, authState) {
                        if (authState is Authenticated) {
                          return HomePage(uid: authState.uid);
                        } else
                          return LoginPage();
                      },
                    );
                  }
                },
              );
            }));
  }
}
