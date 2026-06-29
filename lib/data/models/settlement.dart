import 'camp_region.dart';

/// A refugee settlement within a camp region.
///
/// Examples: Kakuma 1–4, Kalobeyei Village 1–3, Dadaab Main, Hagadera,
/// Ifo 1, Ifo 2, Dagahaley.
class Settlement {
  final String id;
  final String name;
  final CampRegionId regionId;

  /// For Kakuma: zones (A, B, C, D). For Kalobeyei: villages.
  /// For Dadaab: blocks. Each settlement defines its own subdivision scheme.
  final List<String> subdivisions;

  const Settlement({
    required this.id,
    required this.name,
    required this.regionId,
    this.subdivisions = const [],
  });

  factory Settlement.fromMap(Map<String, dynamic> m) => Settlement(
        id: m['id'] as String? ?? '',
        name: m['name'] as String? ?? '',
        regionId: CampRegionIdX.fromId(m['regionId'] as String?),
        subdivisions:
            (m['subdivisions'] as List?)?.cast<String>() ?? const <String>[],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'regionId': id,
        'subdivisions': subdivisions,
      };
}

/// Reference data shipped with the app. In production these are kept in
/// Firestore `camp_regions` and `settlements` collections; the local copy
/// lets the app work offline.
class CampRegionsRef {
  static const List<CampRegion> all = [
    CampRegion(
      id: CampRegionId.kakumaKalobeyei,
      name: 'Kakuma & Kalobeyei',
      campManagerName: 'Kakuma Camp Manager',
      settlementIds: [
        'kakuma_1',
        'kakuma_2',
        'kakuma_3',
        'kakuma_4',
        'kalobeyei_v1',
        'kalobeyei_v2',
        'kalobeyei_v3',
      ],
    ),
    CampRegion(
      id: CampRegionId.dadaabComplex,
      name: 'Dadaab Complex',
      campManagerName: 'Dadaab Camp Manager',
      settlementIds: [
        'dadaab_main',
        'hagadera',
        'ifo_1',
        'ifo_2',
        'dagahaley',
      ],
    ),
  ];

  static const List<Settlement> settlements = [
    Settlement(
      id: 'kakuma_1',
      name: 'Kakuma 1',
      regionId: CampRegionId.kakumaKalobeyei,
      subdivisions: ['Zone A', 'Zone B', 'Zone C', 'Zone D'],
    ),
    Settlement(
      id: 'kakuma_2',
      name: 'Kakuma 2',
      regionId: CampRegionId.kakumaKalobeyei,
      subdivisions: ['Zone A', 'Zone B', 'Zone C', 'Zone D'],
    ),
    Settlement(
      id: 'kakuma_3',
      name: 'Kakuma 3',
      regionId: CampRegionId.kakumaKalobeyei,
      subdivisions: ['Zone A', 'Zone B', 'Zone C', 'Zone D'],
    ),
    Settlement(
      id: 'kakuma_4',
      name: 'Kakuma 4',
      regionId: CampRegionId.kakumaKalobeyei,
      subdivisions: ['Zone A', 'Zone B', 'Zone C', 'Zone D'],
    ),
    Settlement(
      id: 'kalobeyei_v1',
      name: 'Kalobeyei Village 1',
      regionId: CampRegionId.kakumaKalobeyei,
      subdivisions: ['Block A', 'Block B', 'Block C'],
    ),
    Settlement(
      id: 'kalobeyei_v2',
      name: 'Kalobeyei Village 2',
      regionId: CampRegionId.kakumaKalobeyei,
      subdivisions: ['Block A', 'Block B', 'Block C'],
    ),
    Settlement(
      id: 'kalobeyei_v3',
      name: 'Kalobeyei Village 3',
      regionId: CampRegionId.kakumaKalobeyei,
      subdivisions: ['Block A', 'Block B', 'Block C'],
    ),
    Settlement(
      id: 'dadaab_main',
      name: 'Dadaab Main',
      regionId: CampRegionId.dadaabComplex,
      subdivisions: ['Block 1', 'Block 2', 'Block 3', 'Block 4'],
    ),
    Settlement(
      id: 'hagadera',
      name: 'Hagadera',
      regionId: CampRegionId.dadaabComplex,
      subdivisions: ['Block 1', 'Block 2', 'Block 3'],
    ),
    Settlement(
      id: 'ifo_1',
      name: 'Ifo 1',
      regionId: CampRegionId.dadaabComplex,
      subdivisions: ['Block 1', 'Block 2'],
    ),
    Settlement(
      id: 'ifo_2',
      name: 'Ifo 2',
      regionId: CampRegionId.dadaabComplex,
      subdivisions: ['Block 1', 'Block 2'],
    ),
    Settlement(
      id: 'dagahaley',
      name: 'Dagahaley',
      regionId: CampRegionId.dadaabComplex,
      subdivisions: ['Block 1', 'Block 2', 'Block 3'],
    ),
  ];
}
