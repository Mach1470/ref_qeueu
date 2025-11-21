// lib/screens/patient_detail_screen.dart
import 'package:flutter/material.dart';

class PatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmergency = patient['emergency'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F4F1),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(patient['name'] ?? 'Patient'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // --- PROFILE SECTION ---
            Hero(
              tag: "patient_${patient['id'] ?? 'unknown'}",
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: patient['photoUrl'] != null
                    ? Image.network(
                        patient['photoUrl'],
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 130,
                        height: 130,
                        color: Colors.teal.shade100,
                        child: const Icon(Icons.person,
                            size: 70, color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              patient['name'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              "Age ${patient['age'] ?? 'N/A'}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),

            if (isEmergency) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "EMERGENCY",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              )
            ],

            const SizedBox(height: 18),

            // --- INFO CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow("Condition", patient['condition'] ?? 'N/A'),
                  const SizedBox(height: 10),
                  _infoRow("Queue Number", "#${patient['queueNumber'] ?? 'N/A'}"),
                  const SizedBox(height: 10),
                  _infoRow("Status", patient['status'] ?? 'Unknown'),
                ],
              ),
            ),

            const Spacer(),

            // --- ACTION BUTTONS ---
            Column(
              children: [
                _mainButton(
                  "Start Consultation",
                  Icons.medical_services_outlined,
                  Colors.teal,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Consultation started (placeholder)")),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _mainButton(
                  "Mark as Done",
                  Icons.check_circle_outline,
                  Colors.green,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Patient marked as done."),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _mainButton(
                  "Refer",
                  Icons.call_split_outlined,
                  Colors.deepPurple,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Referral options coming.")),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      children: [
        Text(
          "$title: ",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _mainButton(
      String text, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
