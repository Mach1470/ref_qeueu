import 'package:flutter/material.dart';
import 'patient_detail_screen.dart';
import '../models/patient.dart';
import 'map_screen.dart'; // ✅ ADDED

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  _DoctorHomeScreenState createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final List<Patient> _patients = [
    Patient(
      id: "1",
      name: "Mariam A.",
      age: 37,
      condition: "Fever & Cough",
      queueNumber: 1,
      emergency: false,
      status: "Waiting",
      photoUrl: "https://i.pravatar.cc/300?img=1",
    ),
    Patient(
      id: "2",
      name: "James K.",
      age: 42,
      condition: "Chest Pain",
      queueNumber: 2,
      emergency: true,
      status: "Waiting",
      photoUrl: "https://i.pravatar.cc/300?img=2",
    ),
    Patient(
      id: "3",
      name: "Amina L.",
      age: 29,
      condition: "Headache",
      queueNumber: 3,
      emergency: false,
      status: "Waiting",
      photoUrl: "https://i.pravatar.cc/300?img=3",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe8f5f3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            // ✅ LIVE MAP BUTTON ADDED HERE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.location_on),
                  label: const Text(
                    "Open Live Map",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MapScreen()),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSearchBar(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSummaryRow(context),
            ),
            const SizedBox(height: 20),
            _buildLiveQueueTitle(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: _patients.length,
                itemBuilder: (_, index) => _buildPatientTile(_patients[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.teal.shade100,
            child: const Icon(Icons.person, color: Colors.teal, size: 32),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Dr. Stephen Mach",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Cardiology Dept • Juba General",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  // SEARCH BAR
  // ------------------------------------------------------------------------
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.black54),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search patients…",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  // SUMMARY CARDS (Responsive)
  // ------------------------------------------------------------------------
  Widget _buildSummaryRow(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final total = _patients.length;
    final waiting = _patients.where((p) => p.status == 'Waiting').length;
    final emergency = _patients.where((p) => p.emergency).length;

    if (width > 600) {
      return Row(
        children: [
          Expanded(child: _MiniStatCard(title: "Total", value: "$total", icon: Icons.people)),
          const SizedBox(width: 10),
          Expanded(child: _MiniStatCard(title: "Waiting", value: "$waiting", icon: Icons.timer)),
          const SizedBox(width: 10),
          Expanded(child: _MiniStatCard(title: "Emergency", value: "$emergency", icon: Icons.emergency, color: Colors.orange)),
        ],
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        SizedBox(
          width: (width / 2) - 25,
          child: _MiniStatCard(title: "Total", value: "$total", icon: Icons.people),
        ),
        SizedBox(
          width: (width / 2) - 25,
          child: _MiniStatCard(title: "Waiting", value: "$waiting", icon: Icons.timer),
        ),
        SizedBox(
          width: width - 36,
          child: _MiniStatCard(title: "Emergency", value: "$emergency", icon: Icons.emergency, color: Colors.orange),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------------
  // LIVE QUEUE TITLE
  // ------------------------------------------------------------------------
  Widget _buildLiveQueueTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: const [
          Text(
            "Live Queue",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          Icon(Icons.refresh, size: 20),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  // PATIENT TILE
  // ------------------------------------------------------------------------
  Widget _buildPatientTile(Patient p) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientDetailScreen(
              patient: {
                'id': p.id,
                'name': p.name,
                'age': p.age,
                'condition': p.condition,
                'queueNumber': p.queueNumber,
                'photoUrl': p.photoUrl,
                'emergency': p.emergency,
                'status': p.status,
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: p.photoUrl != null
                    ? Image.network(
                        p.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackAvatar(),
                      )
                    : _fallbackAvatar(),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: p.emergency ? Colors.orange.shade800 : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${p.condition} • Age ${p.age}",
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Q#${p.queueNumber}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // fallback avatar
  Widget _fallbackAvatar() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.teal.shade50,
      child: const Icon(Icons.person, size: 32, color: Colors.teal),
    );
  }
}

// MINI STAT CARD
class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const _MiniStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.teal;

    return Container(
      height: 70,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: c.withOpacity(0.15),
            child: Icon(icon, color: c, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
