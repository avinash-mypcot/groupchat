// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBW86tC2tGlzVdx_Jcna21J2p9pt4CBFMQ',
    appId: '1:938618444145:web:e4705d56a4170cbc9afed0',
    messagingSenderId: '938618444145',
    projectId: 'groupchat-436c7',
    authDomain: 'groupchat-436c7.firebaseapp.com',
    storageBucket: 'groupchat-436c7.firebasestorage.app',
    measurementId: 'G-DD03XYKZWN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDs0tzBg1kvn7mKpCf6csIc8bihLk8BDO4',
    appId: '1:938618444145:android:6882d537d8894e4c9afed0',
    messagingSenderId: '938618444145',
    projectId: 'groupchat-436c7',
    storageBucket: 'groupchat-436c7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBPxYPL_W5CoMOmYiAAe1HijWwzJX3dlAw',
    appId: '1:938618444145:ios:708dc4a93917e7e19afed0',
    messagingSenderId: '938618444145',
    projectId: 'groupchat-436c7',
    storageBucket: 'groupchat-436c7.firebasestorage.app',
    iosBundleId: 'com.example.groupchat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBPxYPL_W5CoMOmYiAAe1HijWwzJX3dlAw',
    appId: '1:938618444145:ios:708dc4a93917e7e19afed0',
    messagingSenderId: '938618444145',
    projectId: 'groupchat-436c7',
    storageBucket: 'groupchat-436c7.firebasestorage.app',
    iosBundleId: 'com.example.groupchat',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBW86tC2tGlzVdx_Jcna21J2p9pt4CBFMQ',
    appId: '1:938618444145:web:0817eec883870af89afed0',
    messagingSenderId: '938618444145',
    projectId: 'groupchat-436c7',
    authDomain: 'groupchat-436c7.firebaseapp.com',
    storageBucket: 'groupchat-436c7.firebasestorage.app',
    measurementId: 'G-Q0VKQ5ND8C',
  );

}