import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StepList extends StatelessWidget {
  final List<String> steps;

  const StepList({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    // Theme-aware so step text stays readable in light mode (the legacy
    // AppColors.textPrimary is a fixed dark-theme warm-white).
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Column(
      children: List.generate(steps.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: AppColors.accentBlue,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 15,
                      color: textColor,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
