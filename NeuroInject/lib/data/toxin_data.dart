import 'dart:ui';
import '../models/toxin_brand.dart';

const toxinBrands = [
  ToxinBrand(
    name: 'Botox',
    genericName: 'OnabotulinumtoxinA',
    toxinType: 'Type A',
    vialSizes: [50, 100, 200],
    defaultVial: 100,
    commonDilutions: [
      DilutionPreset(vialUnits: 100, salineMl: 1.0, label: 'Concentrated'),
      DilutionPreset(vialUnits: 100, salineMl: 2.0, label: 'Standard'),
      DilutionPreset(vialUnits: 100, salineMl: 4.0, label: 'Dilute'),
      DilutionPreset(vialUnits: 200, salineMl: 4.0, label: 'Standard (200U)'),
    ],
    storageNote:
        'Store frozen or refrigerated (2-8°C). Reconstituted: use within 24 hrs (refrigerated).',
    maxDoseNote:
        'Max per session: 400 U for spasticity (adult). FDA max across all indications: 360 U/3 months.',
    color: Color(0xFF3D8BFF),
  ),
  ToxinBrand(
    name: 'Xeomin',
    genericName: 'IncobotulinumtoxinA',
    toxinType: 'Type A',
    vialSizes: [50, 100, 200],
    defaultVial: 100,
    commonDilutions: [
      DilutionPreset(vialUnits: 100, salineMl: 1.0, label: 'Concentrated'),
      DilutionPreset(vialUnits: 100, salineMl: 2.0, label: 'Standard'),
      DilutionPreset(vialUnits: 100, salineMl: 4.0, label: 'Dilute'),
      DilutionPreset(vialUnits: 200, salineMl: 4.0, label: 'Standard (200U)'),
    ],
    storageNote:
        'Room temperature storage OK (up to 25°C) before reconstitution. Use within 24 hrs after.',
    maxDoseNote: 'Max per session: 400 U for upper + lower limb spasticity.',
    conversionNote:
        'Xeomin and Botox are generally considered 1:1 unit equivalent for spasticity.',
    color: Color(0xFF9C27B0),
  ),
  ToxinBrand(
    name: 'Dysport',
    genericName: 'AbobotulinumtoxinA',
    toxinType: 'Type A',
    vialSizes: [300, 500],
    defaultVial: 500,
    commonDilutions: [
      DilutionPreset(vialUnits: 500, salineMl: 1.0, label: 'Concentrated'),
      DilutionPreset(vialUnits: 500, salineMl: 2.5, label: 'Standard'),
      DilutionPreset(vialUnits: 500, salineMl: 5.0, label: 'Dilute'),
      DilutionPreset(vialUnits: 300, salineMl: 1.5, label: 'Standard (300U)'),
    ],
    storageNote:
        'Store refrigerated (2-8°C). Reconstituted: use within 4 hrs.',
    maxDoseNote:
        'Max per session: 1500 U for adult lower limb spasticity. Max upper limb: 1000 U.',
    conversionNote:
        'Dysport units are NOT equivalent to Botox/Xeomin.\nConversion: ~2.5-3 Dysport units = 1 Botox unit.\nExample: 100 U Botox ≈ 250-300 U Dysport.',
    color: Color(0xFFFF9800),
  ),
  ToxinBrand(
    name: 'Myobloc',
    genericName: 'RimabotulinumtoxinB',
    toxinType: 'Type B',
    vialSizes: [2500, 5000, 10000],
    defaultVial: 5000,
    preDilutedVolumes: {
      2500: 0.5,
      5000: 1.0,
      10000: 2.0,
    },
    commonDilutions: [
      DilutionPreset(vialUnits: 5000, salineMl: 0, label: 'Pre-diluted (ready to use)'),
      DilutionPreset(vialUnits: 5000, salineMl: 1.0, label: 'Slightly diluted'),
      DilutionPreset(vialUnits: 10000, salineMl: 2.0, label: '10K vial diluted'),
    ],
    storageNote:
        'Store refrigerated (2-8°C). Pre-diluted solution — DO NOT freeze. Use within 4 hrs of opening.',
    maxDoseNote:
        'Typical range: 10,000-25,000 U per session for cervical dystonia/spasticity.',
    conversionNote:
        'Myobloc (Type B) units are NOT interchangeable with ANY Type A toxin.\nConversion: ~50-100 Myobloc units = 1 Botox unit.\nExample: 100 U Botox ≈ 5,000-10,000 U Myobloc.',
    color: Color(0xFF4CAF50),
  ),
];
