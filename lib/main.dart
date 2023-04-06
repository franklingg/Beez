import 'package:beez/constants/app_routes.dart';
import 'package:beez/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initialization().then((value) {
    FlutterNativeSplash.remove();
  });
  runApp(const MyApp());
}

Future<void> initialization() async {
  final stopwatch = Stopwatch();
  const delayTime = 1500;
  stopwatch.start();

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (stopwatch.elapsedMilliseconds < delayTime) {
    await Future.delayed(
        Duration(milliseconds: delayTime - stopwatch.elapsedMilliseconds));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Beez",
      routerConfig: AppRouter.router,
    );
  }
}
