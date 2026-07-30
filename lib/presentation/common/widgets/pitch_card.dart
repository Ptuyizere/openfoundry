import 'package:flutter/material.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/core/theme/colors.dart';
import 'package:openfoundry/data/models/pitch.dart';
import 'package:openfoundry/presentation/common/widgets/funding_progress_bar.dart';


class PitchCard extends StatelessWidget {
  const PitchCard({
    super.key,
    required this.pitch,
    this.onTap,
    this.compact = false,
  });


  final Pitch pitch;
  final VoidCallback? onTap;
  final bool compact;


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pitch.coverImageUrl != null && !compact)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    pitch.coverImageUrl!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 140,
                        color: AppColors.surfaceMuted,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.secondary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, _, _) => Container(
                      height: 140,
                      color: AppColors.surfaceMuted,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      pitch.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusChip(status: pitch.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                pitch.industry,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              FundingProgressBar(raised: pitch.raised, goal: pitch.fundingGoal),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Raised: ${_formatMoney(pitch.raised)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Goal: ${_formatMoney(pitch.fundingGoal)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  String _formatMoney(double v) => v.toStringAsFixed(0);
}


class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final PitchStatus status;


  @override
  Widget build(BuildContext context) {
    final open = status == PitchStatus.open;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: open ? AppColors.accentGold : AppColors.accentSage,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        open ? 'Open' : 'Funded',
        style: const TextStyle(color: AppColors.primary, fontSize: 11),
      ),
    );
  }
}

