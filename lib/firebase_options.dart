// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDPVJt_bTRokd0rcGFcyvClryvOtfQBVcc',
    appId: '1:361330243247:web:3d9d0bed8ea9cd49e4865a',
    messagingSenderId: '361330243247',
    projectId: 'euphony-65e73',
    authDomain: 'euphony-65e73.firebaseapp.com',
    databaseURL: 'https://euphony-65e73-default-rtdb.firebaseio.com',
    storageBucket: 'euphony-65e73.appspot.com',
    measurementId: 'G-E6F4N4N613',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKNJATIkDLfvrU588uosdF54cBouQJ5Pw',
    appId: '1:361330243247:android:e94ac9dfc4207fbae4865a',
    messagingSenderId: '361330243247',
    projectId: 'euphony-65e73',
    databaseURL: 'https://euphony-65e73-default-rtdb.firebaseio.com',
    storageBucket: 'euphony-65e73.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDq6jrmOUta_wUKh_lsMESZ3fSRwCBccSU',
    appId: '1:361330243247:ios:efe2d58fe1523b46e4865a',
    messagingSenderId: '361330243247',
    projectId: 'euphony-65e73',
    databaseURL: 'https://euphony-65e73-default-rtdb.firebaseio.com',
    storageBucket: 'euphony-65e73.appspot.com',
    iosClientId: '361330243247-nrf2eor8j0irdvv81iqjnbi7fmvg1k8o.apps.googleusercontent.com',
    iosBundleId: 'com.example.euphony',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDq6jrmOUta_wUKh_lsMESZ3fSRwCBccSU',
    appId: '1:361330243247:ios:efe2d58fe1523b46e4865a',
    messagingSenderId: '361330243247',
    projectId: 'euphony-65e73',
    databaseURL: 'https://euphony-65e73-default-rtdb.firebaseio.com',
    storageBucket: 'euphony-65e73.appspot.com',
    iosClientId: '361330243247-nrf2eor8j0irdvv81iqjnbi7fmvg1k8o.apps.googleusercontent.com',
    iosBundleId: 'com.example.euphony',
  );
}
