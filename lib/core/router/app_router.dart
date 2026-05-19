import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../services/storage_service.dart';
import '../../models/movie_series.dart';
import '../../screens/welcome/welcome_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/onboarding/quiz_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/category_screens/series_screen.dart';
import '../../screens/home/category_screens/games_screen.dart';
import '../../screens/home/category_screens/books_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/analysis/analysis_screen.dart';
import '../../screens/tests/tests_screen.dart';
import '../../screens/profile/profile_screen.dart';


final routerProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(storageServiceProvider);

  return GoRouter(
    initialLocation: storage.isOnboardingComplete ? '/home' : '/welcome',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(path: '/welcome', builder: (ctx, state) => const WelcomeScreen()),
      GoRoute(path: '/onboarding', builder: (ctx, state) => const OnboardingScreen()),
      GoRoute(path: '/quiz', builder: (ctx, state) => const QuizScreen(isWeekly: false)),
      GoRoute(path: '/weekly-quiz', builder: (ctx, state) => const QuizScreen(isWeekly: true)),
      GoRoute(path: '/home', builder: (ctx, state) => const HomeScreen()),
      GoRoute(path: '/search', builder: (ctx, state) => const SearchScreen()),
      GoRoute(path: '/tests', builder: (ctx, state) => const TestsScreen()),
      GoRoute(path: '/analysis', builder: (ctx, state) => const AnalysisScreen()),
      GoRoute(path: '/profile', builder: (ctx, state) => const ProfileScreen()),
      GoRoute(path: '/category/series', builder: (ctx, state) => const SeriesScreen()),
      GoRoute(path: '/category/games', builder: (ctx, state) => const GamesScreen()),
      GoRoute(path: '/category/books', builder: (ctx, state) => const BooksScreen()),
      GoRoute(
        path: '/series-detail',
        builder: (ctx, state) {
          final item = state.extra as MovieSeries;
          return SeriesDetailScreen(item: item);
        },
      ),
    ],
  );
});
