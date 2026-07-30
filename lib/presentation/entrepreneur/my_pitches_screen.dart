import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openfoundry/core/theme/colors.dart';
import 'package:openfoundry/data/models/pitch.dart';
import 'package:openfoundry/logic/auth/auth_cubit.dart';
import 'package:openfoundry/logic/pitch/pitch_cubit.dart';
import 'package:openfoundry/presentation/common/widgets/empty_state.dart';
import 'package:openfoundry/presentation/common/widgets/pitch_card.dart';
import 'package:openfoundry/router.dart';


class MyPitchesScreen extends StatelessWidget {
  const MyPitchesScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    if (user == null) {
      return const EmptyState(message: 'Sign in to see your pitches.');
    }
    final stream = context.read<PitchCubit>().myPitches(user.id);


    return Scaffold(
      appBar: AppBar(title: const Text('My Pitches')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRoute.pitchForm.name),
        backgroundColor: AppColors.accentGold,
        foregroundColor: AppColors.secondary,
        icon: const Icon(Icons.add),
        label: const Text('New Pitch'),
      ),
      body: StreamBuilder<List<Pitch>>(
        stream: stream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }
          final pitches = snap.data ?? [];
          if (pitches.isEmpty) {
            return const EmptyState(
              message: 'You have not posted any pitches yet.',
              icon: Icons.lightbulb_outline,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: pitches.length,
            itemBuilder: (context, index) {
              final pitch = pitches[index];
              return PitchCard(
                pitch: pitch,
                onTap: () => context.pushNamed(
                  AppRoute.pitchDetail.name,
                  pathParameters: {'id': pitch.id},
                ),
              );
            },
          );
        },
      ),
    );
  }
}

