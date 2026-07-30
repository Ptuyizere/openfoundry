import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:openfoundry/logic/auth/auth_cubit.dart';
import 'package:openfoundry/presentation/auth/login_screen.dart';
import 'package:openfoundry/presentation/auth/signup_screen.dart';

enum AppRoute {
  login,
  signup
}

class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier(this.authCubit) {
    authCubit.stream.listen((_) => notifyListeners());
  }

  final AuthCubit authCubit;
}

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: AuthStateNotifier(authCubit),
    redirect: (context, state) {
      final isAuthenticated =
          authCubit.state.status == AuthStatus.authenticated;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: AppRoute.signup.name,
        builder: (_, _) => const SignupScreen(),
      )
    ],
  );
}

