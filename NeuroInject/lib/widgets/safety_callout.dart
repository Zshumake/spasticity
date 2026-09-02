import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SafetyCallout extends StatelessWidget {
  /// The warnings / danger items to list.
  final List<String> warnings;

  /// Optional title. Defaults to 'Safety'. Callers can pass e.g.
  /// 'Adjacent structures' when rendering muscle-level danger zones.
  final String title;

  /// Optional icon override. Defaults to [Icons.warning_amber_rounded].
  final IconData icon;

  const SafetyCallout({
    super.key,
    required this.warnings,
    this.title = 'Safety',
    this.icon = Icons.warning_amber_rounded,
  });

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
              Icon(icon, size: 18, color: AppColors.warningOrange),
              const SizedBox(width: 6),
              Text(
                title,
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
