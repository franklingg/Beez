import 'package:beez/models/user_model.dart';
import 'package:beez/presentation/event/create_event_screen.dart';
import 'package:beez/presentation/event/event_screen.dart';
import 'package:beez/presentation/feed/feed_screen.dart';
import 'package:beez/presentation/login/login_screen.dart';
import 'package:beez/presentation/login/forgot_password_screen.dart';
import 'package:beez/presentation/map/map_screen.dart';
import 'package:beez/presentation/profile/profile_screen.dart';
import 'package:beez/presentation/register/phone_confirmation_screen.dart';
import 'package:beez/presentation/register/registration_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: "/${RegistrationScreen.name}",
    initialExtra:
        UserModel.initialize('', '', '+55 (83) 98165-9022', DateTime.now()),
    routes: [
      GoRoute(
          path: "/${MapScreen.name}",
          name: MapScreen.name,
          builder: (context, state) => const MapScreen()),
      GoRoute(
          path: "/${FeedScreen.name}",
          name: FeedScreen.name,
          builder: (context, state) => const FeedScreen()),
      GoRoute(
        path: "/${ProfileScreen.name}",
        name: ProfileScreen.name,
        builder: (context, state) => ProfileScreen(id: state.queryParams['id']),
        // ignore: body_might_complete_normally_nullable
        redirect: (context, state) {
          if (state.queryParams['id'] == null ||
              state.queryParams['id']!.isEmpty) return "/${LoginScreen.name}";
        },
      ),
      GoRoute(
          path: "/${EventScreen.name}",
          name: EventScreen.name,
          builder: (context, state) =>
              EventScreen(id: state.queryParams['id'])),
      GoRoute(
          path: "/${CreateEventScreen.name}",
          name: CreateEventScreen.name,
          builder: (context, state) => const CreateEventScreen()),
      GoRoute(
          path: "/${LoginScreen.name}",
          name: LoginScreen.name,
          builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: "/${ForgotPasswordScreen.name}",
          name: ForgotPasswordScreen.name,
          builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(
          path: "/${RegistrationScreen.name}",
          name: RegistrationScreen.name,
          builder: (context, state) => const RegistrationScreen()),
      GoRoute(
          path: "/${PhoneConfirmationScreen.name}",
          name: PhoneConfirmationScreen.name,
          builder: (context, state) {
            UserModel userData = state.extra as UserModel;
            return PhoneConfirmationScreen(userData: userData);
          })
    ],
  );
}
