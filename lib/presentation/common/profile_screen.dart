import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/core/theme/colors.dart';
import 'package:openfoundry/data/models/contribution.dart';
import 'package:openfoundry/logic/auth/auth_cubit.dart';
import 'package:openfoundry/logic/contribution/contribution_cubit.dart';
import 'package:openfoundry/logic/pitch/pitch_cubit.dart';
import 'package:openfoundry/router.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final user = state.user;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textMuted),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.surfaceMuted,
                    backgroundImage: user.profileImageUrl != null
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                    child: user.profileImageUrl == null
                        ? const Icon(Icons.person,
                            size: 44, color: AppColors.textMuted)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(user.email,
                      style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role.label,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.accentGold),
                    ),
                  ),
                  if (user.location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(user.location,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 13)),
                      ],
                    ),
                  ],
                  if (user.bio.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      user.bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.pushNamed(AppRoute.editProfile.name),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit profile'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (user.role == UserRole.entrepreneur) ...[
                    _buildSummaryCard(context, user.id, user.role),
                  ] else ...[
                    _buildSummaryCard(context, user.id, user.role),
                  ],
                ],
              ),
            ),
    );
  }


  Widget _buildSummaryCard(
      BuildContext context, String userId, UserRole role) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role == UserRole.entrepreneur
                  ? 'Your impact'
                  : 'Your contributions',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 12),
            if (role == UserRole.entrepreneur)
              _EntrepreneurStats(userId: userId)
            else
              _BackerStats(userId: userId),
          ],
        ),
      ),
    );
  }
}


class _EntrepreneurStats extends StatelessWidget {
  const _EntrepreneurStats({required this.userId});
  final String userId;


  @override
  Widget build(BuildContext context) {
    final pitches = context.watch<PitchCubit>().myPitches(userId);
    final contributions =
        context.watch<ContributionCubit>().fundersOfEntrepreneur(userId);


    final pitchesCount = StreamBuilder<List>(
      stream: pitches,
      builder: (_, snap) => Text(
        '${(snap.data ?? []).length}',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: AppColors.secondary,
        ),
      ),
    );
    final contributionsCount = StreamBuilder<List<Contribution>>(
      stream: contributions,
      builder: (_, snap) {
        final list = snap.data ?? [];
        var total = 0.0;
        for (final c in list) {
          total += c.amount;
        }
        return Text(
          '\$${total.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppColors.accentGold,
          ),
        );
      },
    );


    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            pitchesCount,
            const SizedBox(height: 4),
            const Text('Pitches', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        const SizedBox(width: 24),
        Column(
          children: [
            contributionsCount,
            const SizedBox(height: 4),
            const Text('Raised', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        const SizedBox(width: 24),
        Column(
          children: [
            StreamBuilder<List<Contribution>>(
              stream: contributions,
              builder: (_, snap) => Text(
                '${(snap.data ?? []).length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: AppColors.accentSage,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text('Backers', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}


class _BackerStats extends StatelessWidget {
  const _BackerStats({required this.userId});
  final String userId;


  @override
  Widget build(BuildContext context) {
    final contributions =
        context.watch<ContributionCubit>().myFunding(userId);


    return StreamBuilder<List<Contribution>>(
      stream: contributions,
      builder: (_, snap) {
        final list = snap.data ?? [];
        var total = 0.0;
        final pitchIds = <String>{};
        for (final c in list) {
          total += c.amount;
          pitchIds.add(c.pitchId);
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  '\$${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: AppColors.accentGold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Total funded',
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(width: 24),
            Column(
              children: [
                Text(
                  '${pitchIds.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Pitches backed',
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(width: 24),
            Column(
              children: [
                Text(
                  '${list.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: AppColors.accentSage,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Contributions',
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ],
        );
      },
    );
  }
}
