class Patient {
  final String id;
  final String name;
  final int age;
  final String condition;
  final int queueNumber;
  final bool emergency;
  final String status;
  final String? photoUrl;
  final String? prescription; // NEW

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.condition,
    required this.queueNumber,
    required this.emergency,
    required this.status,
    this.photoUrl,
    this.prescription,
  });
}
