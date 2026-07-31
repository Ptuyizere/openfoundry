import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/core/theme/colors.dart';
import 'package:openfoundry/data/models/contribution.dart';
import 'package:openfoundry/logic/auth/auth_cubit.dart';
import 'package:openfoundry/logic/contribution/contribution_cubit.dart';
import 'package:openfoundry/presentation/common/widgets/empty_state.dart';


class MyFundingScreen extends StatelessWidget {
  const MyFundingScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    if (user == null) {
      return const EmptyState(message: 'Sign in to see your funding.');
    }
    final stream = context.read<ContributionCubit>().myFunding(user.id);


    return Scaffold(
      appBar: AppBar(title: const Text('My contributions')),
      body: StreamBuilder<List<Contribution>>(
        stream: stream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }
          final contributions = snap.data ?? [];
          if (contributions.isEmpty) {
            return const EmptyState(
              message: 'You have not funded any pitches yet.',
              icon: Icons.handshake_outlined,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: contributions.length,
            itemBuilder: (context, index) {
              final c = contributions[index];
              return _ContributionCard(contribution: c);
            },
          );
        },
      ),
    );
  }
}


class _ContributionCard extends StatelessWidget {
  const _ContributionCard({required this.contribution});
  final Contribution contribution;


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contribution.pitchTitle,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'by ${contribution.entrepreneurName}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${contribution.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.accentGold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    contribution.fundingType.label,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.phone_android,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  contribution.paymentMethod.label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
                if (contribution.shares != null) ...[
                  const Spacer(),
                  Text(
                    '${contribution.shares!} shares',
                    style: const TextStyle(
                      color: AppColors.accentSage,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
