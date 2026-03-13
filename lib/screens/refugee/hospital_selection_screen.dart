import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ref_qeueu/services/database_service.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';

class HospitalSelectionScreen extends StatefulWidget {
  const HospitalSelectionScreen({super.key});

  @override
  State<HospitalSelectionScreen> createState() =>
      _HospitalSelectionScreenState();
}

class _HospitalSelectionScreenState extends State<HospitalSelectionScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  Position? _currentPosition;
  String? _locationError;
  String? _selectedHospitalId;

  // Mocked list of hospitals for now. In Phase 6/7, these will come from Firestore.
  // Using fac_001 because the mock database schema uses it.
  final List<Map<String, dynamic>> _hospitals = [
    {
      'id': 'fac_001',
      'name': 'Kakuma General Hospital',
      'distance': '1.2 km',
      'waitTime': 'Approx. 45 mins',
      'type': 'General',
    },
    {
      'id': 'fac_002',
      'name': 'Clinic 3 - Maternity & Pediatrics',
      'distance': '2.5 km',
      'waitTime': 'Approx. 20 mins',
      'type': 'Specialized',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationError = 'Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationError = 'Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationError =
            'Location permissions are permanently denied, we cannot request permissions.');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _joinQueue() async {
    if (_selectedHospitalId == null) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Missing profile/symptom data')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Add symptoms to profile blob
      final profile = {
        'name': args['name'] ?? 'Unknown',
        'id': args['individualNumber'] ?? args['id'] ?? 'SELF',
        'age': args['age'] ?? '',
        'gender': args['gender'] ?? '',
        'isFamily': args['isFamily'] ?? false,
        'symptoms': args['symptoms'] ?? '',
        'symptomDuration': args['symptomDuration'] ?? '',
        'severity': args['severity'] ?? 'Medium',
      };

      await DatabaseService.instance.addToJoinQueue(
        profile,
        hospitalId: _selectedHospitalId!,
        lat: _currentPosition?.latitude,
        lng: _currentPosition?.longitude,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined the queue!')));

      // Pop all the way back to the main refugee home screen
      Navigator.popUntil(context, ModalRoute.withName('/refugee_home_new'));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error joining queue: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF386BB8);

    return SafeScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select Hospital',
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_locationError != null)
                  Container(
                    width: double.infinity,
                    color: Colors.orange.shade100,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "$_locationError\nShowing all hospitals instead of nearby.",
                            style: TextStyle(
                                color: Colors.orange.shade900, fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: _fetchLocation,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    color: Colors.green.shade50,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.green.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Location found. Showing nearby hospitals.',
                          style: TextStyle(
                              color: Colors.green.shade800, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _hospitals.length,
                    itemBuilder: (context, index) {
                      final hospital = _hospitals[index];
                      final isSelected = _selectedHospitalId == hospital['id'];

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedHospitalId = hospital['id']);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor.withOpacity(0.05)
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.local_hospital,
                                    color: primaryColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hospital['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.directions_walk,
                                            size: 14,
                                            color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(hospital['distance'],
                                            style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13)),
                                        const SizedBox(width: 12),
                                        Icon(Icons.access_time,
                                            size: 14,
                                            color: Colors.orange.shade700),
                                        const SizedBox(width: 4),
                                        Text(hospital['waitTime'],
                                            style: TextStyle(
                                                color: Colors.orange.shade700,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: primaryColor)
                              else
                                Icon(Icons.radio_button_unchecked,
                                    color: Colors.grey.shade400),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            (_selectedHospitalId != null && !_isSubmitting)
                                ? _joinQueue
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Join Queue',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
