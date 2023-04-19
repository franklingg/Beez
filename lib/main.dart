import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_routes.dart';
import 'package:beez/models/user_model.dart';
import 'package:beez/services/firebase_options.dart';
import 'package:beez/utils/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initialization();
  final allUsers = await getUsers();
  FlutterNativeSplash.remove();
  runApp(MyApp(initialUsers: allUsers));
}

Future<void> initialization() async {
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('pt_BR');
}

Future<List<UserModel>> getUsers() async {
  try {
    final db = FirebaseFirestore.instance;
    final query = await db.collection('users').get();
    final users = query.docs.map((doc) => UserModel.fromMap(doc)).toList();
    return users;
  } catch (e) {
    return Future.error(e);
  }
}

class MyApp extends StatelessWidget {
  final List<UserModel> initialUsers;
  const MyApp({Key? key, required this.initialUsers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProvider>(
        create: (context) {
          final provider = UserProvider();
          provider.addAll(initialUsers);
          return provider;
        },
        child: MaterialApp.router(
            theme: ThemeData(
              primaryColor: AppColors.yellow,
              textTheme: GoogleFonts.notoSansTextTheme(const TextTheme(
                  displayMedium: TextStyle(
                      fontSize: 15,
                      color: AppColors.black,
                      fontWeight: FontWeight.w600),
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
