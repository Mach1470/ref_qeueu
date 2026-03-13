// Path constants for Firestore access
const String kPharmacyQueuePath =
    'artifacts/__app_id/public/data/pharmacyQueue';
const String kPharmacyHistoryPath =
    'artifacts/__app_id/public/data/pharmacyHistory';

// Utility function to format a Duration object into HH:MM:SS string
String formatDurationDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$hours:$minutes:$seconds";
}
