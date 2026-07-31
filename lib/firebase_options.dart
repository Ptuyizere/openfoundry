import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA8RioA0QMJDHaSLhqhwftY2gqI845pKiU',
    appId: '1:754132084093:web:f3bdb329b7ad8662309814',
    messagingSenderId: '754132084093',
    projectId: 'openfoundry-1262c',
    authDomain: 'openfoundry-1262c.firebaseapp.com',
    storageBucket: 'openfoundry-1262c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBTyNTpeflB8Cpjau7wgCmZFwyERN65aYU',
    appId: '1:754132084093:android:b1380b8bfb7f0314309814',
    messagingSenderId: '754132084093',
    projectId: 'openfoundry-1262c',
    storageBucket: 'openfoundry-1262c.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA5VxkXcnmB8KRw11NiHitRPSdS1VCd6uY',
    appId: '1:754132084093:ios:3da73a3741246119309814',
    messagingSenderId: '754132084093',
    projectId: 'openfoundry-1262c',
    storageBucket: 'openfoundry-1262c.firebasestorage.app',
    iosBundleId: 'com.openfoundry.openfoundry',
  );
}


