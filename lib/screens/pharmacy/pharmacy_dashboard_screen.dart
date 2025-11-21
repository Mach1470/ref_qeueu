// lib/screens/pharmacy/pharmacy_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'pharmacy_models.dart';
import 'pharmacy_patient_detail_screen.dart';

class PharmacyDashboardScreen extends StatefulWidget {
  const PharmacyDashboardScreen({super.key});

  @override
  State<PharmacyDashboardScreen> createState() => _PharmacyDashboardScreenState();
}

class _PharmacyDashboardScreenState extends State<PharmacyDashboardScreen> {
  // Example in-memory queue. Replace with Firestore later.
  final List<Patient> _queue = [
    Patient(
      id: "1",
      name: "John Deng",
      condition: "Malaria",
      prescriptionText: "Artemether + Paracetamol (10 tabs)",
      photoUrl: null,
      queueNumber: 1,
    ),
    Patient(
      id: "2",
      name: "Mary Akot",
      condition: "Diarrhea",
      prescriptionText: null, // doctor wrote on paper
      photoUrl: null,
      queueNumber: 2,
    ),
    Patient(
      id: "3",
      name: "Mariam A.",
      condition: "Fever",
      prescriptionText: "Paracetamol 500mg - 2 tabs",
      photoUrl: null,
      queueNumber: 3,
    ),
  ];

  void _markServed(Patient p) {
    setState(() {
      p.served = true;
      _queue.removeWhere((x) => x.id == p.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as served')));
  }

  @override
  Widget build(BuildContext context) {
    final waitingCount = _queue.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pharmacy Dashboard"),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Overview row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: _overviewCard('Queue', '$waitingCount')),
                  const SizedBox(width: 12),
                  Expanded(child: _overviewCard('Pending scripts', '${_queue.where((p) => p.prescriptionText != null).length}')),
                ],
              ),
            ),

            Expanded(
              child: _queue.isEmpty
                  ? Center(child: Text('No patients in queue', style: TextStyle(color: Colors.grey.shade600)))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: _queue.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final p = _queue[index];
                        return _patientCard(p);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overviewCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3))]),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.teal.shade50, child: Text(value, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _patientCard(Patient p) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PharmacyPatientDetailScreen(
                patient: p,
                onMarkServed: () => _markServed(p),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // avatar / placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.teal.shade50,
                  child: p.photoUrl != null
                      ? Image.network(p.photoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.teal))
                      : const Icon(Icons.person, size: 36, color: Colors.teal),
                ),
              ),

              const SizedBox(width: 12),

              // Expanded to avoid overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(p.condition, style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (p.prescriptionText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(Icons.description, size: 14, color: Colors.green),
                                const SizedBox(width: 6),
                                Text('Prescription', style: TextStyle(fontSize: 12, color: Colors.green.shade800)),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(Icons.note, size: 14, color: Colors.orange),
                                const SizedBox(width: 6),
                                Text('Ask for paper script', style: TextStyle(fontSize: 12, color: Colors.orange.shade800)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // queue number & arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (p.queueNumber != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text('#${p.queueNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.teal),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
