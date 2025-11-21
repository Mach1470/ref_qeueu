// lib/models/medicine.dart
class Medicine {
  final String id;
  final String name;
  final String description;
  final bool free;
  final String dosage; // e.g. "500mg"
  final double price; // kept for later if needed (but we display FREE)

  Medicine({
    required this.id,
    required this.name,
    required this.description,
    this.free = true,
    this.dosage = '',
    this.price = 0.0,
  });
}
