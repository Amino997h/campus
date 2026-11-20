import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDul35ZRfqi2mOuslRrrAIy2AkZAUY43Fo',
    appId: '1:256171839420:web:3e064c8abc9b82a450a5b9',
    messagingSenderId: '256171839420',
    projectId: 'campus-2fd9e',
    authDomain: 'campus-2fd9e.firebaseapp.com',
    storageBucket: 'campus-2fd9e.firebasestorage.app',
    measurementId: 'G-9QS53T03FJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyATXGcDOYnzPmbn3qI6mhYBxsZymUaLwTU',
    appId: '1:256171839420:android:4075fc68de569ec750a5b9',
    messagingSenderId: '256171839420',
    projectId: 'campus-2fd9e',
    storageBucket: 'campus-2fd9e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDul35ZRfqi2mOuslRrrAIy2AkZAUY43Fo',
    appId: '1:256171839420:android:4075fc68de569ec750a5b9',
    messagingSenderId: '256171839420',
    projectId: 'campus-2fd9e',
    storageBucket: 'campus-2fd9e.firebasestorage.app',
  );
}
