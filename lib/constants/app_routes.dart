import 'package:beez/presentation/feed/feed_screen.dart';
import 'package:beez/presentation/map/map_screen.dart';
import 'package:beez/presentation/profile/profile_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: "/map",
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
              ProfileScreen(id: int.parse(state.queryParams['id'] ?? "-1"))),
    ],
  );
}
