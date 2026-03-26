// ─────────────────────────────────────────────────────────────────────────────
// Dummy survey data — 45 records (FIXED)
// ─────────────────────────────────────────────────────────────────────────────
import '../models/survey_model.dart';

final List<SurveyModel> dummySurveys = [
  SurveyModel(
    id: '#882',
    sequenceNumber: 1,
    totalSequence: 45,
    ownerName: 'The owner of Survey No...',
    taluka: 'Agra',
    village: 'Lakhanpur',
    surveyNo: '233/2',
    farmlandPlotId: 'UP124573413857',
    farmerTotalArea: 0.017,
    surveyorName: 'UMA KUMARI',
    farmAllocation: DateTime(2026, 1, 4, 8, 14),
    surveyDate: DateTime(2026, 1, 31, 10, 37),
    submissionDate: DateTime(2026, 2, 1, 11, 47),
    latitude: 27.200005,
    longitude: 77.91705,
    mapCoordinateLabel: '233/2/124573/0233000212',
    reviewedImages: [
      SurveyImage(
        landUsage: 'NA Area (Non-agricultural)',
        cropAreaType: 'अचानक',
        area: 0.017,
        areaUnit: 'Hectare',
        colorHex: 0xFF8BC34A,
        cropSowingDate: '-',
        cropStatus: 'Not Sown',
        cropClassName: '-',
        irrigationSource: '-',
        remarks: 'No crop data',
      ),
    ],
  ),

  SurveyModel(
    id: '#941',
    sequenceNumber: 2,
    totalSequence: 45,
    ownerName: 'Suresh Deshmukh',
    taluka: 'Mulshi',
    village: 'Paud',
    surveyNo: '101/A',
    farmlandPlotId: 'MH204573413988',
    farmerTotalArea: 0.512,
    surveyorName: 'PRIYA SINGH',
    farmAllocation: DateTime(2026, 1, 3, 8, 0),
    surveyDate: DateTime(2026, 1, 7, 14, 45),
    submissionDate: DateTime(2026, 1, 8, 9, 10),
    latitude: 18.5360,
    longitude: 73.6820,
    mapCoordinateLabel: '101/A/2026/9876543210222',
    reviewedImages: [
      SurveyImage(
        landUsage: 'Agricultural Land',
        cropAreaType: 'Wheat',
        area: 0.495,
        areaUnit: 'Hectare',
        colorHex: 0xFF4CAF50,
        cropSowingDate: '10 Jan, 2026',
        cropStatus: 'Standing',
        cropClassName: 'Rabi',
        irrigationSource: 'Canal',
        remarks: 'Healthy crop',
      ),
      SurveyImage(
        landUsage: 'NA Area (Non-agricultural)',
        cropAreaType: 'अचानक',
        area: 0.017,
        areaUnit: 'Hectare',
        colorHex: 0xFF9E9E9E,
        cropSowingDate: '-',
        cropStatus: 'Not Sown',
        cropClassName: '-',
        irrigationSource: '-',
        remarks: 'No crop present',
      ),
    ],
  ),

  // ─────────────────────────────────────────────────────────
  // AUTO GENERATED (3 → 45)
  // ─────────────────────────────────────────────────────────
  ...List.generate(43, (i) {
    final idx = i + 3;

    const talukas = [
      'Khed',
      'Mulshi',
      'Haveli',
      'Maval',
      'Bhor',
      'Agra',
      'Mathura'
    ];

    const surveyors = [
      'UMA KUMARI',
      'PRIYA SINGH',
      'AJAY KUMAR',
      'KAVITA MEENA',
      'RAJESH PATEL'
    ];

    const crops = ['Wheat', 'Rice', 'Sugarcane', 'Mustard', 'Cotton'];

    const colorHexes = [
      0xFF4CAF50,
      0xFF8BC34A,
      0xFFFFC107,
      0xFF2196F3,
      0xFF9C27B0,
      0xFF607D8B
    ];

    final area =
    double.parse(((idx * 0.073) % 1.9 + 0.05).toStringAsFixed(3));

    final isAgri = idx % 2 == 0;

    return SurveyModel(
      id: '#${1300 + idx * 17}',
      sequenceNumber: idx,
      totalSequence: 45,
      ownerName: 'Survey Owner No. $idx',
      taluka: talukas[idx % talukas.length],
      village: 'Village ${idx * 3}',
      surveyNo: '${idx * 10 + 1}/${(idx % 5) + 1}',
      farmlandPlotId:
      'MH${(idx * 1000000 + 234567).toString().padLeft(12, '0')}',
      farmerTotalArea: area,
      surveyorName: surveyors[idx % surveyors.length],
      farmAllocation: DateTime(2026, 1, (idx % 27) + 1, 8, 0),
      surveyDate: DateTime(2026, 1, (idx % 27) + 2, 10, 0),
      submissionDate: DateTime(2026, 1, (idx % 27) + 3, 11, 0),
      latitude: 18.3 + (idx * 0.018),
      longitude: 73.5 + (idx * 0.014),
      mapCoordinateLabel:
      '${idx * 10 + 1}/${(idx % 5) + 1}/2026/${idx * 8765432}',

      reviewedImages: [
        SurveyImage(
          landUsage: isAgri
              ? 'Agricultural Land'
              : 'NA Area (Non-agricultural)',

          cropAreaType: isAgri
              ? crops[idx % crops.length]
              : 'अचानक',

          area: area,
          areaUnit: 'Hectare',
          colorHex: colorHexes[idx % colorHexes.length],

          cropSowingDate:
          isAgri ? '${(idx % 28) + 1} Jan, 2026' : '-',

          cropStatus: isAgri
              ? ['Standing', 'Harvested', 'Damaged'][idx % 3]
              : 'Not Sown',

          cropClassName: isAgri ? 'Rabi' : '-',

          irrigationSource: isAgri
              ? ['Canal', 'Borewell', 'Drip'][idx % 3]
              : '-',

          remarks: isAgri
              ? 'Field condition normal'
              : 'No crop present',
        ),
      ],
    );
  }),
];