import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LandmarkList extends StatelessWidget {
  final List<String> landmarks;

  const LandmarkList({super.key, required this.landmarks});

  @override
  Widget build(BuildContext context) {
    // Theme-aware so landmark text stays readable in light mode (the legacy
    // AppColors.textPrimary is a fixed dark-theme warm-white).
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Column(
      children: landmarks.map((landmark) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accentBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  landmark,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
