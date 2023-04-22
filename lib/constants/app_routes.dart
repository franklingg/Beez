import 'package:beez/presentation/event/event_screen.dart';
import 'package:beez/presentation/feed/feed_screen.dart';
import 'package:beez/presentation/map/map_screen.dart';
import 'package:beez/presentation/profile/profile_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: "/${MapScreen.name}",
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
          builder: (context, state) =>
              ProfileScreen(id: state.queryParams['id'])),
      GoRoute(
          path: "/${EventScreen.name}",
          name: EventScreen.name,
          builder: (context, state) =>
              EventScreen(id: state.queryParams['id'])),
    ],
  );
}
