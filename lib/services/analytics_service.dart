import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ref_qeueu/models/analytics_models.dart';

class AnalyticsService {
  AnalyticsService._privateConstructor();
  static final AnalyticsService instance =
      AnalyticsService._privateConstructor();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection paths
  CollectionReference get _treatmentsRef =>
      _db.collection('analytics/system/treatments');

  CollectionReference get _birthsRef =>
      _db.collection('analytics/system/births');

  /// Log a treatment event
  Future<void> logTreatment(TreatmentEvent event) async {
    await _treatmentsRef.add(event.toMap());
  }

  /// Log a birth
  Future<void> logBirth(BirthRecord record) async {
    await _birthsRef.add(record.toMap());
  }

  /// Get treatment count for a date range
  Future<int> getTreatmentCount({
    String? facilityId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _treatmentsRef;

    if (facilityId != null) {
      query = query.where('facilityId', isEqualTo: facilityId);
    }

    if (startDate != null) {
      query = query.where('timestamp',
          isGreaterThanOrEqualTo: startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.where('timestamp',
          isLessThanOrEqualTo: endDate.toIso8601String());
    }

    final snapshot = await query.get();
    return snapshot.docs.length;
  }

  /// Get daily treatment counts for the last N days
  Future<Map<DateTime, int>> getDailyTreatmentCounts({
    String? facilityId,
    int days = 30,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    Query query = _treatmentsRef
        .where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String());

    if (facilityId != null) {
      query = query.where('facilityId', isEqualTo: facilityId);
    }

    final snapshot = await query.get();

    // Group by date
    final Map<DateTime, int> counts = {};
    for (final doc in snapshot.docs) {
      final event = TreatmentEvent.fromMap(doc.data() as Map<String, dynamic>);
      final dateKey = DateTime(
          event.timestamp.year, event.timestamp.month, event.timestamp.day);
      counts[dateKey] = (counts[dateKey] ?? 0) + 1;
    }

    return counts;
  }

  /// Get illness frequency (diagnosis breakdown)
  Future<Map<String, int>> getIllnessFrequency({
    String? facilityId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _treatmentsRef;

    if (facilityId != null) {
      query = query.where('facilityId', isEqualTo: facilityId);
    }

    if (startDate != null) {
      query = query.where('timestamp',
          isGreaterThanOrEqualTo: startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.where('timestamp',
          isLessThanOrEqualTo: endDate.toIso8601String());
    }

    final snapshot = await query.get();

    final Map<String, int> frequency = {};
    for (final doc in snapshot.docs) {
      final event = TreatmentEvent.fromMap(doc.data() as Map<String, dynamic>);
      if (event.diagnosis != null && event.diagnosis!.isNotEmpty) {
        frequency[event.diagnosis!] = (frequency[event.diagnosis!] ?? 0) + 1;
      }
    }

    return frequency;
  }

  /// Get age demographic breakdown
  Future<Map<String, int>> getAgeDemographics({
    String? facilityId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _treatmentsRef;

    if (facilityId != null) {
      query = query.where('facilityId', isEqualTo: facilityId);
    }

    if (startDate != null) {
      query = query.where('timestamp',
          isGreaterThanOrEqualTo: startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.where('timestamp',
          isLessThanOrEqualTo: endDate.toIso8601String());
    }

    final snapshot = await query.get();

    // Categorize ages
    final Map<String, int> demographics = {
      '0-5': 0,
      '6-12': 0,
      '13-18': 0,
      '19-35': 0,
      '36-60': 0,
      '60+': 0,
      'Unknown': 0,
    };

    for (final doc in snapshot.docs) {
      final event = TreatmentEvent.fromMap(doc.data() as Map<String, dynamic>);
      if (event.age != null) {
        final age = int.tryParse(event.age!);
        if (age != null) {
          if (age <= 5) {
            demographics['0-5'] = demographics['0-5']! + 1;
          } else if (age <= 12) {
            demographics['6-12'] = demographics['6-12']! + 1;
          } else if (age <= 18) {
            demographics['13-18'] = demographics['13-18']! + 1;
          } else if (age <= 35) {
            demographics['19-35'] = demographics['19-35']! + 1;
          } else if (age <= 60) {
            demographics['36-60'] = demographics['36-60']! + 1;
          } else {
            demographics['60+'] = demographics['60+']! + 1;
          }
        } else {
          demographics['Unknown'] = demographics['Unknown']! + 1;
        }
      } else {
        demographics['Unknown'] = demographics['Unknown']! + 1;
      }
    }

    return demographics;
  }

  /// Get birth statistics
  Future<Map<String, dynamic>> getBirthStatistics({
    String? facilityId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _birthsRef;

    if (facilityId != null) {
      query = query.where('facilityId', isEqualTo: facilityId);
    }

    if (startDate != null) {
      query = query.where('birthDate',
          isGreaterThanOrEqualTo: startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.where('birthDate',
          isLessThanOrEqualTo: endDate.toIso8601String());
    }

    final snapshot = await query.get();

    int totalBirths = snapshot.docs.length;
    int maleCount = 0;
    int femaleCount = 0;
    int complications = 0;

    for (final doc in snapshot.docs) {
      final birth = BirthRecord.fromMap(doc.data() as Map<String, dynamic>);
      if (birth.babyGender.toLowerCase() == 'male') maleCount++;
      if (birth.babyGender.toLowerCase() == 'female') femaleCount++;
      if (birth.complications) complications++;
    }

    return {
      'total': totalBirths,
      'male': maleCount,
      'female': femaleCount,
      'complications': complications,
    };
  }

  /// Get readmission rate
  Future<double> getReadmissionRate({
    String? facilityId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _treatmentsRef;

    if (facilityId != null) {
      query = query.where('facilityId', isEqualTo: facilityId);
    }

    if (startDate != null) {
      query = query.where('timestamp',
          isGreaterThanOrEqualTo: startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.where('timestamp',
          isLessThanOrEqualTo: endDate.toIso8601String());
    }

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) return 0.0;

    int readmissions = 0;
    for (final doc in snapshot.docs) {
      final event = TreatmentEvent.fromMap(doc.data() as Map<String, dynamic>);
      if (event.isReadmission) readmissions++;
    }

    return (readmissions / snapshot.docs.length) * 100;
  }
}
