import 'package:flutter/material.dart';
import 'package:openfoundry/core/theme/colors.dart';


class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message});


  final String? message;


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.secondary,
            strokeWidth: 2,
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: const TextStyle(color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }
}
