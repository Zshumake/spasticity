import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/toxin_brand.dart';
import '../../data/toxin_data.dart';
import '../../widgets/syringe_visual.dart';
import '../../widgets/dilution_explainer.dart';

// ─── Calculator Screen ───────────────────────────────────────

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  int _brandIndex = 0;
  late double _vialSize;
  double _dilution = 2.0;
  double _dose = 50;

  late TextEditingController _vialController;
  late TextEditingController _doseController;

  ToxinBrand get _brand => toxinBrands[_brandIndex];

  @override
  void initState() {
    super.initState();
    _vialSize = _brand.defaultVial.toDouble();
    _vialController = TextEditingController(text: _vialSize.toStringAsFixed(0));
    _doseController = TextEditingController(text: _dose.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _vialController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  bool get _isMyoblocNoDilution =>
      _brand.name == 'Myobloc' && _dilution == 0;

  double get _concentration {
    if (_isMyoblocNoDilution) {
      // Myobloc is pre-diluted: 2500U/0.5mL, 5000U/1.0mL, 10000U/2.0mL
      // All work out to 5000 U/mL, but use the actual volumes to be precise.
      final preDilutedMl =
          _brand.preDilutedVolumeFor(_vialSize.toInt()) ?? 1.0;
      return _vialSize / preDilutedMl;
    }
    return _dilution > 0 ? _vialSize / _dilution : 0;
  }

  double get _volume => _concentration > 0 ? _dose / _concentration : 0;

  double get _unitsPer01ml => _concentration * 0.1;

  /// The total liquid volume in the syringe after reconstitution (or pre-diluted volume).
  double get _totalLiquidVolume {
    if (_isMyoblocNoDilution) {
      return _brand.preDilutedVolumeFor(_vialSize.toInt()) ?? 1.0;
    }
    return _dilution;
  }

  void _selectBrand(int index) {
    final brand = toxinBrands[index];
    setState(() {
      _brandIndex = index;
      _vialSize = brand.defaultVial.toDouble();
      _vialController.text = _vialSize.toStringAsFixed(0);
      // Reset dilution to a sensible default
      if (brand.commonDilutions.length > 1) {
        _dilution = brand.commonDilutions[1].salineMl;
      } else {
        _dilution = brand.commonDilutions[0].salineMl;
      }
      // Reset dose for each brand's unit scale
      if (brand.name == 'Myobloc') {
        _dose = 2500;
        _doseController.text = '2500';
      } else if (brand.name == 'Dysport') {
        _dose = 250;
        _doseController.text = '250';
      } else {
        _dose = 50;
        _doseController.text = '50';
      }
    });
  }

  void _applyPreset(DilutionPreset preset) {
    setState(() {
      _vialSize = preset.vialUnits.toDouble();
      _vialController.text = preset.vialUnits.toString();
      _dilution = preset.salineMl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toxin Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand selector
            _buildBrandSelector(),
            const SizedBox(height: 16),

            // Brand info card
            _buildBrandInfoCard(),
            const SizedBox(height: 20),

            // Common dilutions quick-pick
            _buildDilutionPresets(),
            const SizedBox(height: 20),

            // Calculator inputs
            _buildCalculatorInputs(),
            const SizedBox(height: 24),

            // Results
            _buildResults(),

            // Conversion warning
            if (_brand.conversionNote != null) ...[
              const SizedBox(height: 16),
              _buildConversionCard(),
            ],

            // Syringe visual
            const SizedBox(height: 24),
            _sectionLabel('YOUR SYRINGE'),
            const SizedBox(height: 4),
            Text(
              'Each tick mark on a 1 mL syringe = 0.1 mL',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SyringeVisual(
                concentrationPerMl: _concentration,
                highlightVolumeMl: _volume.clamp(0.0, 1.0),
                brandColor: _brand.color,
              ),
            ),

            // Step-by-step math explanation
            const SizedBox(height: 24),
            DilutionExplainer(
              brandName: _brand.name,
              vialUnits: _vialSize,
              salineMl: _dilution,
              totalLiquidMl: _totalLiquidVolume,
              desiredDose: _dose,
              brandColor: _brand.color,
            ),

            // Dilution reference table
            const SizedBox(height: 20),
            _buildDilutionTable(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Brand Selector ──────────────────────────────────────

  Widget _buildBrandSelector() {
    return Row(
      children: List.generate(toxinBrands.length, (i) {
        final brand = toxinBrands[i];
        final selected = i == _brandIndex;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => _selectBrand(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? brand.color : const Color(0xFF1D2128),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? brand.color : AppColors.borderColor,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  brand.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─── Brand Info Card ─────────────────────────────────────

  Widget _buildBrandInfoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _brand.color.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _brand.color.withAlpha(60)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _brand.color.withAlpha(50),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _brand.toxinType,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _brand.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _brand.genericName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _infoRow(Icons.inventory_2_outlined, 'Vials',
                  _brand.vialSizes.map((v) => '$v U').join(', ')),
              const SizedBox(height: 6),
              _infoRow(Icons.thermostat_outlined, 'Storage',
                  _brand.storageNote),
              const SizedBox(height: 6),
              _infoRow(Icons.speed_outlined, 'Max dose',
                  _brand.maxDoseNote),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            )),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              )),
        ),
      ],
    );
  }

  // ─── Dilution Presets ────────────────────────────────────

  Widget _buildDilutionPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('COMMON DILUTIONS — TAP TO APPLY'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _brand.commonDilutions.map((preset) {
            final isActive = _vialSize == preset.vialUnits.toDouble() &&
                _dilution == preset.salineMl;
            final concText = preset.salineMl > 0
                ? '${preset.concentration.toStringAsFixed(0)} U/mL'
                : 'Pre-diluted';
            return GestureDetector(
              onTap: () => _applyPreset(preset),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? _brand.color.withAlpha(30)
                      : const Color(0xFF1D2128),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive ? _brand.color : AppColors.borderColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? _brand.color
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preset.salineMl > 0
                          ? '${preset.vialUnits}U + ${preset.salineMl.toStringAsFixed(1)} mL'
                          : '${preset.vialUnits}U (ready to use)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      concText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? _brand.color
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Calculator Inputs ───────────────────────────────────

  Widget _buildCalculatorInputs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('VIAL SIZE (UNITS)'),
          const SizedBox(height: 8),
          // Vial size quick-pick chips
          Row(
            children: _brand.vialSizes.map((size) {
              final selected = _vialSize == size.toDouble();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$size U'),
                  selected: selected,
                  selectedColor: _brand.color.withAlpha(50),
                  backgroundColor: const Color(0xFF1D2128),
                  side: BorderSide(
                    color: selected ? _brand.color : AppColors.borderColor,
                  ),
                  labelStyle: TextStyle(
                    color: selected ? _brand.color : AppColors.textSecondary,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _vialSize = size.toDouble();
                      _vialController.text = size.toString();
                    });
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Dilution stepper
          _sectionLabel('SALINE ADDED (mL)'),
          const SizedBox(height: 8),
          _buildStepper(),
          const SizedBox(height: 16),

          // Desired dose
          _sectionLabel('DESIRED DOSE (UNITS PER MUSCLE)'),
          const SizedBox(height: 8),
          _buildDoseField(),
        ],
      ),
    );
  }

  Widget _buildDoseField() {
    final maxDose = _brand.name == 'Myobloc'
        ? 25000.0
        : _brand.name == 'Dysport'
            ? 1500.0
            : 400.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _doseController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) {
            final parsed = double.tryParse(v);
            if (parsed != null && parsed >= 0) {
              setState(() => _dose = parsed.clamp(0, maxDose));
            } else if (v.isEmpty) {
              setState(() => _dose = 0);
            }
          },
          style:
              const TextStyle(fontSize: 18, color: AppColors.textPrimary),
        ),
        if (_dose > maxDose) ...[
          const SizedBox(height: 4),
          Text(
            'Exceeds typical max (${maxDose.toStringAsFixed(0)} U). Verify intent.',
            style: const TextStyle(fontSize: 12, color: AppColors.warningOrange),
          ),
        ],
      ],
    );
  }

  Widget _buildStepper() {
    final step = _brand.name == 'Myobloc' ? 1.0 : 0.5;
    final min = _brand.name == 'Myobloc' ? 0.0 : 0.5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1D2128),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _dilution > min
                ? () => setState(() => _dilution -= step)
                : null,
            icon: const Icon(Icons.remove),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Text(
              _dilution == 0
                  ? 'Pre-diluted (no saline)'
                  : '${_dilution.toStringAsFixed(1)} mL',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: _dilution < 10
                ? () => setState(() => _dilution += step)
                : null,
            icon: const Icon(Icons.add),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  // ─── Results ─────────────────────────────────────────────

  Widget _buildResults() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          _resultRow(
            'Concentration',
            '${_concentration.toStringAsFixed(0)} U/mL',
            AppColors.accentBlue,
          ),
          const Divider(color: AppColors.borderColor, height: 24),
          _resultRow(
            'Per 0.1 mL',
            '${_unitsPer01ml.toStringAsFixed(1)} U',
            AppColors.probeTeal,
          ),
          const Divider(color: AppColors.borderColor, height: 24),
          _resultRow(
            'Volume to inject',
            '${_volume.toStringAsFixed(2)} mL',
            AppColors.successGreen,
          ),
          const SizedBox(height: 12),
          // Plain English summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _buildSummaryText(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildSummaryText() {
    if (_concentration <= 0) return 'Enter values above to calculate.';
    final dilutionText = _dilution > 0
        ? '${_dilution.toStringAsFixed(1)} mL saline'
        : 'no added saline (pre-diluted in ${_totalLiquidVolume.toStringAsFixed(1)} mL)';
    return 'With ${_vialSize.toStringAsFixed(0)} U of ${_brand.name} '
        'diluted in $dilutionText:\n'
        'Each 0.1 mL = ${_unitsPer01ml.toStringAsFixed(1)} units.\n'
        'To give ${_dose.toStringAsFixed(0)} U → draw up ${_volume.toStringAsFixed(2)} mL.';
  }

  Widget _resultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16, color: AppColors.textPrimary)),
        Text(value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            )),
      ],
    );
  }

  // ─── Conversion Card ─────────────────────────────────────

  Widget _buildConversionCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withAlpha(20),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: const Border(
          left: BorderSide(color: AppColors.warningOrange, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.swap_horiz_rounded,
              size: 20, color: AppColors.warningOrange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _brand.conversionNote!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade200,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dilution Reference Table ────────────────────────────

  Widget _buildDilutionTable() {
    // Show how much is in each 0.1 mL for common dilutions
    final vial = _vialSize;
    final dilutions = _brand.name == 'Myobloc'
        ? [1.0, 2.0, 3.0, 5.0]
        : [1.0, 2.0, 4.0, 5.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(
            'QUICK REFERENCE: ${vial.toStringAsFixed(0)} U VIAL'),
        const SizedBox(height: 4),
        Text(
          'Units per 0.1 mL at different dilutions',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            children: [
              // Header row
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: const [
                    Expanded(
                        flex: 2,
                        child: Text('Saline',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary))),
                    Expanded(
                        flex: 2,
                        child: Text('U/mL',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary))),
                    Expanded(
                        flex: 2,
                        child: Text('Per 0.1 mL',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary))),
                  ],
                ),
              ),
              // Data rows
              ...dilutions.map((d) {
                final conc = vial / d;
                final per01 = conc * 0.1;
                final isCurrentDilution =
                    (d - _dilution).abs() < 0.01;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isCurrentDilution
                        ? _brand.color.withAlpha(15)
                        : null,
                    border: Border(
                      top: BorderSide(
                          color: AppColors.borderColor, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${d.toStringAsFixed(1)} mL',
                          style: TextStyle(
                            fontSize: 14,
                            color: isCurrentDilution
                                ? _brand.color
                                : AppColors.textPrimary,
                            fontWeight: isCurrentDilution
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${conc.toStringAsFixed(0)} U/mL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isCurrentDilution
                                ? _brand.color
                                : AppColors.textPrimary,
                            fontWeight: isCurrentDilution
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${per01.toStringAsFixed(1)} U',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isCurrentDilution
                                ? _brand.color
                                : AppColors.successGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1,
      ),
    );
  }
}
