import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_locales.dart';
import 'package:beez/constants/app_routes.dart';
import 'package:beez/providers/event_provider.dart';
import 'package:beez/services/event_service.dart';
import 'package:beez/services/firebase_service.dart';
import 'package:beez/services/notification_service.dart';
import 'package:beez/services/user_service.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: depend_on_referenced_packages
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
  await Firebase.initializeApp(options: FirebaseService.currentPlatform);
  await NotificationService.initialize();
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();

  // if (initialLink != null) {
  //   final Uri deepLink = initialLink.link;
  //   // Example of using the dynamic link to push the user to a different screen
  //   // Navigator.pushNamed(context, deepLink.path);
  // }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          FutureProvider<UserProvider>(
              initialData: UserProvider(),
              create: (userContext) async {
                final provider = UserProvider();
                final initialUsers = await UserService.getUsers();
                provider.addAll(initialUsers);
                // await FirebaseService.linkListen(userContext);
                return provider;
              }),
          FutureProvider<EventProvider>(
              initialData: EventProvider(),
              create: (eventContext) async {
                final provider = EventProvider();
                final initialEvents = await EventService.getEvents();
                provider.addAll(initialEvents);
                return provider;
              })
        ],
        child: MaterialApp.router(
            localizationsDelegates: const [
              CountryLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            supportedLocales: AppLocales.all,
            locale: AppLocales.defaultLocale,
            theme: ThemeData(
              primaryColor: AppColors.yellow,
              textTheme: GoogleFonts.notoSansTextTheme(const TextTheme(
                  headlineLarge: TextStyle(fontSize: 17, color: AppColors.blue),
                  headlineMedium:
                      TextStyle(fontSize: 14, color: AppColors.blue),
                  displayMedium:
                      TextStyle(fontSize: 16, color: AppColors.black),
                  displaySmall: TextStyle(fontSize: 13, color: AppColors.brown),
                  bodyLarge: TextStyle(fontSize: 18, color: AppColors.black),
                  bodyMedium: TextStyle(fontSize: 15, color: AppColors.black),
                  bodySmall: TextStyle(fontSize: 13, color: AppColors.black),
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
