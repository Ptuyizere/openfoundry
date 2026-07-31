import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/core/theme/colors.dart';
import 'package:openfoundry/data/models/contribution.dart';
import 'package:openfoundry/logic/auth/auth_cubit.dart';
import 'package:openfoundry/logic/contribution/contribution_cubit.dart';
import 'package:openfoundry/presentation/common/widgets/empty_state.dart';


class FundersScreen extends StatelessWidget {
  const FundersScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    if (user == null) {
      return const EmptyState(message: 'Sign in to see who funded you.');
    }
    final stream =
        context.read<ContributionCubit>().fundersOfEntrepreneur(user.id);


    return Scaffold(
      appBar: AppBar(title: const Text('Who funded me')),
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
              message: 'No one has funded your pitches yet.',
              icon: Icons.people_outline,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: contributions.length,
            itemBuilder: (context, index) {
              final c = contributions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              c.pitchTitle,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            c.createdAt.toString().substring(0, 10),
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Backed by ${c.backerName}',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${c.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColors.accentGold,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  c.fundingType.label,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              if (c.shares != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${c.shares!} shares',
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
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
