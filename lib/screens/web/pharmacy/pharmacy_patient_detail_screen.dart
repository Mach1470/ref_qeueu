import 'package:flutter/material.dart';
import 'pharmacy_models.dart';

class PharmacyPatientDetailScreen extends StatelessWidget {
  final Patient patient;
  final VoidCallback onMarkServed;

  const PharmacyPatientDetailScreen({
    super.key,
    required this.patient,
    required this.onMarkServed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient.name),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 70,
                      height: 70,
                      color: Colors.teal.shade50,
                      child: patient.photoUrl != null
                          ? Image.network(patient.photoUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.person,
                              size: 40, color: Colors.teal),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      patient.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              Text("Condition",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800)),
              const SizedBox(height: 6),
              Text(patient.condition,
                  style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 20),

              Text("Prescription",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800)),
              const SizedBox(height: 6),

              patient.prescriptionText != null
                  ? Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        patient.prescriptionText!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Doctor wrote prescription on paper.\nPlease ask patient to show script.",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onMarkServed();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text(
                    "Mark as Served",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

