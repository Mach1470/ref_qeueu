/// Represents a camp region in the MyQueque multi-camp system.
///
/// Currently supported: Kakuma & Kalobeyei, Dadaab Complex.
/// The architecture is designed so new regions (e.g. Rhino Camp, Bidibidi,
/// Nyarugusu, South Sudan settlements) can be added without code changes —
/// just new records in the `camp_regions` Firestore collection.
enum CampRegionId {
  kakumaKalobeyei,
  dadaabComplex,
  unknown,
}

extension CampRegionIdX on CampRegionId {
  String get id {
    switch (this) {
      case CampRegionId.kakumaKalobeyei:
        return 'kakuma_kalobeyei';
      case CampRegionId.dadaabComplex:
        return 'dadaab_complex';
      case CampRegionId.unknown:
        return 'unknown';
    }
  }

  String get displayName {
    switch (this) {
      case CampRegionId.kakumaKalobeyei:
        return 'Kakuma & Kalobeyei';
      case CampRegionId.dadaabComplex:
        return 'Dadaab Complex';
      case CampRegionId.unknown:
        return 'Unknown Region';
    }
  }

  static CampRegionId fromId(String? raw) {
    switch (raw) {
      case 'kakuma_kalobeyei':
        return CampRegionId.kakumaKalobeyei;
      case 'dadaab_complex':
        return CampRegionId.dadaabComplex;
      default:
        return CampRegionId.unknown;
    }
  }
}

class CampRegion {
  final CampRegionId id;
  final String name;
  final String campManagerName;
  final List<String> settlementIds;

  const CampRegion({
    required this.id,
    required this.name,
    required this.campManagerName,
    required this.settlementIds,
  });
}
