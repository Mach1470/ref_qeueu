// lib/screens/pharmacy/pharmacy_models.dart
class Patient {
  String id;
  String name;
  String condition;
  String? prescriptionText;
  String? photoUrl;
  int? queueNumber;
  bool served;

  Patient({
    required this.id,
    required this.name,
    required this.condition,
    this.prescriptionText,
    this.photoUrl,
    this.queueNumber,
    this.served = false,
  });
}
