import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SafetyCallout extends StatelessWidget {
  final List<String> warnings;

  const SafetyCallout({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withAlpha(25),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(
          left: BorderSide(
            color: AppColors.warningOrange,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 18, color: AppColors.warningOrange),
              const SizedBox(width: 6),
              Text(
                'Safety',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warningOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...warnings.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  w,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.warningOrange.withAlpha(200),
                    height: 1.4,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
