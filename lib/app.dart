import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openfoundry/core/theme/theme.dart';
import 'package:openfoundry/data/repositories/auth_repository.dart';
import 'package:openfoundry/data/repositories/contribution_repository.dart';
import 'package:openfoundry/data/repositories/pitch_repository.dart';
import 'package:openfoundry/data/repositories/storage_repository.dart';
import 'package:openfoundry/data/repositories/user_repository.dart';
import 'package:openfoundry/logic/auth/auth_cubit.dart';
import 'package:openfoundry/logic/contribution/contribution_cubit.dart';
import 'package:openfoundry/logic/pitch/browse_cubit.dart';
import 'package:openfoundry/logic/pitch/pitch_cubit.dart';
import 'package:openfoundry/logic/profile/profile_cubit.dart';
import 'package:openfoundry/router.dart';

class OpenFoundryApp extends StatefulWidget {
  const OpenFoundryApp({super.key});

  @override
  State<OpenFoundryApp> createState() => _OpenFoundryAppState();
}

class _OpenFoundryAppState extends State<OpenFoundryApp> {
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authRepo = AuthRepository();
    final userRepo = UserRepository();

    _authCubit = AuthCubit(
      authRepository: authRepo,
      userRepository: userRepo,
    )..checkSession();

    _router = createRouter(_authCubit);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider(
          create: (_) => PitchCubit(
            pitchRepository: PitchRepository(),
            storageRepository: StorageRepository(),
          ),
        ),
        BlocProvider(
          create: (_) => BrowseCubit(pitchRepository: PitchRepository()),
        ),
        BlocProvider(
          create: (_) => ContributionCubit(
            contributionRepository: ContributionRepository(),
          ),
        ),
        BlocProvider(
          create: (_) => ProfileCubit(
            userRepository: UserRepository(),
            storageRepository: StorageRepository(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'OpenFoundry',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        routerConfig: _router,
      ),
    );
  }
}












