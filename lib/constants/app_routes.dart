import 'package:beez/presentation/map/map_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: "/map",
    routes: [
      GoRoute(
          path: "/${MapScreen.name}",
          name: MapScreen.name,
          builder: (context, state) => const MapScreen()),
    ],
  );
}
