import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_routes.dart';
import 'package:beez/models/user_model.dart';
import 'package:beez/services/firebase_options.dart';
import 'package:beez/services/user_service.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  initialization().then((_) {
    runApp(const MyApp());
    FlutterNativeSplash.remove();
  });
}

Future initialization() async {
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

extension AppDateExtension on DateTime {
  DateTime getDateOnly() {
    return DateTime(year, month, day);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureProvider<UserProvider>(
        initialData: UserProvider(),
        create: (context) async {
          final provider = UserProvider();
          final initialUsers = await UserService.getUsers();
          provider.addAll(initialUsers);
          return provider;
        },
        child: MaterialApp.router(
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('pt', 'BR')],
            theme: ThemeData(
              primaryColor: AppColors.yellow,
              textTheme: GoogleFonts.notoSansTextTheme(const TextTheme(
                  headlineMedium:
                      TextStyle(fontSize: 14, color: AppColors.blue),
                  displayMedium:
                      TextStyle(fontSize: 16, color: AppColors.black),
                  displaySmall: TextStyle(fontSize: 13, color: AppColors.brown),
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
                  labelMedium:
                      TextStyle(fontSize: 16, color: AppColors.mediumGrey),
                  labelSmall: TextStyle(
                      fontSize: 12,
                      color: AppColors.black,
                      letterSpacing: 0.6))),
            ),
            title: "Beez",
            routerConfig: AppRouter.router));
  }
}
