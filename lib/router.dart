import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:openfoundry/data/models/pitch.dart';
import 'package:openfoundry/logic/auth/auth_cubit.dart';
import 'package:openfoundry/presentation/auth/login_screen.dart';
import 'package:openfoundry/presentation/auth/signup_screen.dart';
import 'package:openfoundry/presentation/backer/browse_screen.dart';
import 'package:openfoundry/presentation/backer/fund_pitch_screen.dart';
import 'package:openfoundry/presentation/backer/my_funding_screen.dart';
import 'package:openfoundry/presentation/backer/pitch_detail_screen.dart';
import 'package:openfoundry/presentation/common/edit_profile_screen.dart';
import 'package:openfoundry/presentation/common/home_screen.dart';
import 'package:openfoundry/presentation/common/profile_screen.dart';
import 'package:openfoundry/presentation/entrepreneur/funders_screen.dart';
import 'package:openfoundry/presentation/entrepreneur/my_pitches_screen.dart';
import 'package:openfoundry/presentation/entrepreneur/pitch_form_screen.dart';

enum AppRoute {
  login,
  signup,
  home,
  pitchForm,
  pitchDetail,
  pitchEdit,
  fundPitch,
  myPitches,
  funders,
  myFunding,
  browse,
  profile,
  editProfile,
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
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home.name,
        builder: (_, state) {
          final tab =
              int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return HomeScreen(initialTab: tab);
        },
      ),
      GoRoute(
        path: '/pitch/new',
        name: AppRoute.pitchForm.name,
        builder: (_, state) {
          final pitch = state.extra as Pitch?;
          return PitchFormScreen(pitch: pitch);
        },
      ),
      GoRoute(
        path: '/pitch/:id',
        name: AppRoute.pitchDetail.name,
        builder: (_, state) => PitchDetailScreen(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/pitch/:id/edit',
        name: AppRoute.pitchEdit.name,
        builder: (_, state) {
          final pitch = state.extra as Pitch?;
          return PitchFormScreen(pitch: pitch);
        },
      ),
      GoRoute(
        path: '/pitch/:id/fund',
        name: AppRoute.fundPitch.name,
        builder: (_, state) => FundPitchScreen(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/my-pitches',
        name: AppRoute.myPitches.name,
        builder: (_, _) => const MyPitchesScreen(),
      ),
      GoRoute(
        path: '/funders',
        name: AppRoute.funders.name,
        builder: (_, _) => const FundersScreen(),
      ),
      GoRoute(
        path: '/my-funding',
        name: AppRoute.myFunding.name,
        builder: (_, _) => const MyFundingScreen(),
      ),
      GoRoute(
        path: '/browse',
        name: AppRoute.browse.name,
        builder: (_, _) => const BrowseScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: AppRoute.profile.name,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: AppRoute.editProfile.name,
        builder: (_, _) => const EditProfileScreen(),
      ),
    ],
  );
}


