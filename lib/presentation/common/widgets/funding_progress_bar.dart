import 'package:flutter/material.dart';
import 'package:openfoundry/core/theme/colors.dart';


class FundingProgressBar extends StatelessWidget {
  const FundingProgressBar({
    super.key,
    required this.raised,
    required this.goal,
  });


  final double raised;
  final double goal;


  @override
  Widget build(BuildContext context) {
    final progress = goal <= 0 ? 0.0 : (raised / goal).clamp(0.0, 1.0);
    final isComplete = raised >= goal;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        backgroundColor: AppColors.surfaceMuted,
        valueColor: AlwaysStoppedAnimation(
          isComplete ? AppColors.accentSage : AppColors.accentGold,
        ),
      ),
    );
  }
}

