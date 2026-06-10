import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  // Проект inlek-api — синхронизировано с android/app/google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdoQGVFw4Uj9XhYH_uFleXGDhy-OeA97g',
    appId: '1:722661675975:android:29754d95b75e91805a3fe2',
    messagingSenderId: '722661675975',
    projectId: 'inlek-api',
    storageBucket: 'inlek-api.firebasestorage.app',
  );

  // Проект inlek-api — синхронизировано с ios/GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD2MBY8cEWOcFT6ZCqpYmAQ5fUeCjt2YxE',
    appId: '1:722661675975:ios:c2df2fd18b6fc3cf5a3fe2',
    messagingSenderId: '722661675975',
    projectId: 'inlek-api',
    storageBucket: 'inlek-api.firebasestorage.app',
    iosBundleId: 'com.dkmfarm.inlek.app',
  );
}
