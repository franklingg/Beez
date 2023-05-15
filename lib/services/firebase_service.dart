import 'package:beez/presentation/profile/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

enum LinkType {
  event,
  user;
}

class FirebaseService {
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

  static FirebaseOptions web = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_WEB_API_KEY']!,
    appId: dotenv.env['FIREBASE_WEB_APP_ID']!,
    messagingSenderId: dotenv.env['FIREBASE_WEB_MESSAGING_SENDER_ID']!,
    projectId: dotenv.env['FIREBASE_WEB_PROJECT_ID']!,
    authDomain: dotenv.env['FIREBASE_WEB_AUTH_DOMAIN']!,
    storageBucket: dotenv.env['FIREBASE_WEB_STORAGE_BUCKET']!,
  );

  static FirebaseOptions android = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY']!,
    appId: dotenv.env['FIREBASE_ANDROID_APP_ID']!,
    messagingSenderId: dotenv.env['FIREBASE_ANDROID_MESSAGING_SENDER_ID']!,
    projectId: dotenv.env['FIREBASE_ANDROID_PROJECT_ID']!,
    storageBucket: dotenv.env['FIREBASE_ANDROID_STORAGE_BUCKET']!,
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_IOS_API_KEY']!,
    appId: dotenv.env['FIREBASE_IOS_APP_ID']!,
    messagingSenderId: dotenv.env['FIREBASE_IOS_MESSAGING_SENDER_ID']!,
    projectId: dotenv.env['FIREBASE_IOS_PROJECT_ID']!,
    storageBucket: dotenv.env['FIREBASE_IOS_STORAGE_BUCKET']!,
    iosClientId: dotenv.env['FIREBASE_IOS_IOS_CLIENT_ID']!,
    iosBundleId: dotenv.env['FIREBASE_IOS_IOS_BUNDLE_ID']!,
  );

  static FirebaseOptions macos = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_MACOS_API_KEY']!,
    appId: dotenv.env['FIREBASE_MACOS_APP_ID']!,
    messagingSenderId: dotenv.env['FIREBASE_MACOS_MESSAGING_SENDER_ID']!,
    projectId: dotenv.env['FIREBASE_MACOS_PROJECT_ID']!,
    storageBucket: dotenv.env['FIREBASE_MACOS_STORAGE_BUCKET']!,
    iosClientId: dotenv.env['FIREBASE_MACOS_IOS_CLIENT_ID']!,
    iosBundleId: dotenv.env['FIREBASE_MACOS_IOS_BUNDLE_ID']!,
  );

  static Future<String> createEventLink(LinkType type, String id) async {
    final dynamicLinkParams = DynamicLinkParameters(
        link: Uri.parse("beezapp.page.link/user?id=$id"),
        uriPrefix: "https://beezapp.page.link/",
        androidParameters: const AndroidParameters(
          // TODO: add PlayStore url
          // fallbackUrl: Uri(path: ""),
          packageName: "com.example.beez",
          minimumVersion: 30,
        ));
    final link =
        await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);
    return link.toString();
  }

  static Future<void> linkListen(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
      final deepLink = dynamicLink.link;
      final isUser = deepLink.pathSegments.contains('user');
      final isEvent = deepLink.pathSegments.contains('event');
      if (isUser) {
        String? id = deepLink.queryParameters['id'];
        if (id != null) {
          GoRouter.of(context)
              .pushNamed(ProfileScreen.name, queryParams: {'id': id});
        }
      }
    });
  }
}
