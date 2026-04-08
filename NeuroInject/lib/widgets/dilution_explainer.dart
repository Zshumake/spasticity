import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Step-by-step visual explanation of dilution math.
/// Shows the conceptual pipeline: Vial → Add Saline → Concentration → Draw Volume.
class DilutionExplainer extends StatelessWidget {
  final String brandName;
  final double vialUnits;
  final double salineMl;

  /// The actual total liquid volume after reconstitution or pre-dilution.
  /// For reconstituted toxins this equals [salineMl].
  /// For pre-diluted Myobloc this is the manufacturer's volume (e.g. 0.5, 1.0, 2.0 mL).
  final double totalLiquidMl;

  final double desiredDose;
  final Color brandColor;

  const DilutionExplainer({
    super.key,
    required this.brandName,
    required this.vialUnits,
    required this.salineMl,
    required this.totalLiquidMl,
    required this.desiredDose,
    required this.brandColor,
  });

  double get _concentration => totalLiquidMl > 0 ? vialUnits / totalLiquidMl : 0;
  double get _volumeToInject =>
      _concentration > 0 ? desiredDose / _concentration : 0;

  bool get _isPreDiluted => salineMl == 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 51 : 13),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.school_outlined, size: 20, color: brandColor),
                  const SizedBox(width: 8),
                  Text(
                    'How This Calculation Works',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: brandColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Step 1: The vial
              _buildStep(
                stepNumber: 1,
                title: 'Start with the vial',
                explanation: _isPreDiluted
                    ? 'Your $brandName vial contains ${vialUnits.toStringAsFixed(0)} units '
                        'of toxin as a ready-to-use liquid solution in '
                        '${totalLiquidMl.toStringAsFixed(1)} mL.'
                    : 'Your $brandName vial contains ${vialUnits.toStringAsFixed(0)} units '
                        'of toxin as a freeze-dried powder. '
                        'The powder by itself has no volume — it needs to be reconstituted.',
                formula: '${vialUnits.toStringAsFixed(0)} U in the vial',
                icon: Icons.science_outlined,
              ),
              _stepConnector(),

              // Step 2: Add saline
              _buildStep(
                stepNumber: 2,
                title: _isPreDiluted
                    ? 'No reconstitution needed'
                    : 'Add preservative-free normal saline',
                explanation: _isPreDiluted
                    ? '$brandName is pre-diluted by the manufacturer at '
                        '${vialUnits.toStringAsFixed(0)} U in '
                        '${totalLiquidMl.toStringAsFixed(1)} mL. '
                        'No saline is added — draw directly from the vial.'
                    : 'You inject ${salineMl.toStringAsFixed(1)} mL of saline into the vial. '
                        'The toxin dissolves into this saline. More saline = more dilute solution. '
                        'Less saline = more concentrated.\n\n'
                        'Think of it like mixing juice concentrate — more water means weaker juice.',
                formula: _isPreDiluted
                    ? 'Pre-diluted: ${vialUnits.toStringAsFixed(0)} U in ${totalLiquidMl.toStringAsFixed(1)} mL'
                    : '${vialUnits.toStringAsFixed(0)} U dissolved in ${salineMl.toStringAsFixed(1)} mL',
                icon: Icons.water_drop_outlined,
              ),
              _stepConnector(),

              // Step 3: Calculate concentration
              _buildStep(
                stepNumber: 3,
                title: 'Calculate the concentration',
                explanation:
                    'Divide the total units by the total volume to get units per mL.\n\n'
                    'This tells you: "In every 1 mL of this solution, there are '
                    '${_concentration.toStringAsFixed(0)} units of $brandName."',
                formula:
                    '${vialUnits.toStringAsFixed(0)} U ÷ ${totalLiquidMl.toStringAsFixed(1)} mL = '
                    '${_concentration.toStringAsFixed(0)} U/mL',
                isKeyFormula: true,
                icon: Icons.calculate_outlined,
              ),
              _stepConnector(),

              // Step 4: Per 0.1 mL
              _buildStep(
                stepNumber: 4,
                title: 'Know what\'s in each 0.1 mL',
                explanation:
                    'Most syringes are marked in 0.1 mL increments. '
                    'Since the concentration is ${_concentration.toStringAsFixed(0)} U/mL, '
                    'each 0.1 mL contains one-tenth of that.\n\n'
                    'This is the number you\'ll use at the bedside — '
                    'each tick mark on your syringe = '
                    '${(_concentration * 0.1).toStringAsFixed(1)} units.',
                formula:
                    '${_concentration.toStringAsFixed(0)} U/mL × 0.1 mL = '
                    '${(_concentration * 0.1).toStringAsFixed(1)} U per 0.1 mL',
                isKeyFormula: true,
                icon: Icons.straighten_outlined,
              ),
              _stepConnector(),

              // Step 5: Calculate injection volume
              _buildStep(
                stepNumber: 5,
                title: 'Calculate how much to draw up',
                explanation:
                    'You want to give ${desiredDose.toStringAsFixed(0)} units to this muscle. '
                    'Divide your desired dose by the concentration to find the volume.\n\n'
                    'Draw up ${_volumeToInject.toStringAsFixed(2)} mL in your syringe — '
                    'that\'s your injection volume.',
                formula:
                    '${desiredDose.toStringAsFixed(0)} U ÷ ${_concentration.toStringAsFixed(0)} U/mL = '
                    '${_volumeToInject.toStringAsFixed(2)} mL',
                isKeyFormula: true,
                icon: Icons.vaccines_outlined,
              ),

              const SizedBox(height: 20),

              // Summary box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: brandColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: brandColor.withAlpha(60)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: brandColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${vialUnits.toStringAsFixed(0)} U $brandName '
                      '+ ${_isPreDiluted ? "no added saline (${totalLiquidMl.toStringAsFixed(1)} mL pre-diluted)" : "${salineMl.toStringAsFixed(1)} mL saline"}\n'
                      '→ ${_concentration.toStringAsFixed(0)} U per mL '
                      '(${(_concentration * 0.1).toStringAsFixed(1)} U per 0.1 mL)\n'
                      '→ Draw up ${_volumeToInject.toStringAsFixed(2)} mL '
                      'to give ${desiredDose.toStringAsFixed(0)} U',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildStep({
    required int stepNumber,
    required String title,
    required String explanation,
    required String formula,
    required IconData icon,
    bool isKeyFormula = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step number circle
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: brandColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNumber',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: brandColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                explanation,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              // Formula box
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isKeyFormula
                      ? brandColor.withAlpha(20)
                      : Colors.white.withAlpha(8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isKeyFormula
                        ? brandColor.withAlpha(80)
                        : AppColors.borderColor,
                  ),
                ),
                child: Text(
                  formula,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    color: isKeyFormula ? brandColor : AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 4, bottom: 4),
      child: Container(
        width: 2,
        height: 20,
        color: AppColors.borderColor,
      ),
    );
  }
}
