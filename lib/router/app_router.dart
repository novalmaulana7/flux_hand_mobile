import 'package:go_router/go_router.dart';
import '../feature/hand_tracker/presentation/pages/hand_tracker_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(path: '/', builder: (context, state) => const HandTrackerPage()),
    ],
  );
}
