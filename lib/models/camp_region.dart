/// Geographic region (camp) — top-level scope for facilities and patients.
class CampRegion {
  final String id;
  final String name;
  final String country;
  final double centerLat;
  final double centerLng;

  /// List of zone/settlement IDs that belong to this camp.
  final List<String> settlementIds;

  const CampRegion({
    required this.id,
    required this.name,
    required this.country,
    required this.centerLat,
    required this.centerLng,
    this.settlementIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'centerLat': centerLat,
    'centerLng': centerLng,
    'settlementIds': settlementIds,
  };

  factory CampRegion.fromJson(Map<String, dynamic> json) => CampRegion(
    id: json['id'] as String,
    name: json['name'] as String,
    country: json['country'] as String? ?? '',
    centerLat: (json['centerLat'] as num?)?.toDouble() ?? 0,
    centerLng: (json['centerLng'] as num?)?.toDouble() ?? 0,
    settlementIds: (json['settlementIds'] as List?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
  );
}

/// A zone or settlement within a camp (e.g. "Kakuma 1, Zone 2").
class Settlement {
  final String id;
  final String name;
  final String campRegionId;
  final double lat;
  final double lng;
  final int? population;

  const Settlement({
    required this.id,
    required this.name,
    required this.campRegionId,
    required this.lat,
    required this.lng,
    this.population,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'campRegionId': campRegionId,
    'lat': lat,
    'lng': lng,
    'population': population,
  };

  factory Settlement.fromJson(Map<String, dynamic> json) => Settlement(
    id: json['id'] as String,
    name: json['name'] as String,
    campRegionId: json['campRegionId'] as String,
    lat: (json['lat'] as num?)?.toDouble() ?? 0,
    lng: (json['lng'] as num?)?.toDouble() ?? 0,
    population: json['population'] as int?,
  );
}
