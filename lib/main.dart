import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_routes.dart';
import 'package:beez/services/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

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
        theme: ThemeData(
          primaryColor: AppColors.yellow,
          textTheme: GoogleFonts.notoSansTextTheme(const TextTheme(
              displayMedium: TextStyle(
                  fontSize: 15,
                  color: AppColors.black,
                  fontWeight: FontWeight.w600),
              bodyMedium: TextStyle(fontSize: 15, color: AppColors.black),
              bodySmall: TextStyle(fontSize: 12, color: AppColors.yellow),
              titleLarge: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black),
              titleMedium: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black),
              titleSmall: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white),
              labelMedium: TextStyle(fontSize: 16, color: AppColors.mediumGrey),
              labelSmall: TextStyle(
                  fontSize: 12, color: AppColors.black, letterSpacing: 0.6))),
        ),
        title: "Beez",
        routerConfig: AppRouter.router);
  }
}
