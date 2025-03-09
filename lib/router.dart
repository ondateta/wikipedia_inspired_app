import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:template/src/views/auth/login_view.dart';
import 'package:template/src/views/auth/register_view.dart';
import 'package:template/src/views/home/home_screen.dart';
import 'package:template/src/views/pages/create_page_view.dart';
import 'package:template/src/views/pages/edit_page_view.dart';
import 'package:template/src/views/pages/page_detail_view.dart';
import 'package:template/src/views/splash_view.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const SplashView(),
      ),
      redirect: (context, state) {
        final userBox = Hive.box('userData');
        final isLoggedIn = userBox.get('isLoggedIn', defaultValue: false);
        
        if (isLoggedIn) {
          return '/home';
        } else {
          return '/login';
        }
      },
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const LoginView(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const RegisterView(),
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/create-page',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const CreatePageView(),
      ),
    ),
    GoRoute(
      path: '/page/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return NoTransitionPage(
          child: PageDetailView(pageId: id),
        );
      },
    ),
    GoRoute(
      path: '/edit-page/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return NoTransitionPage(
          child: EditPageView(pageId: id),
        );
      },
    ),
  ],
);