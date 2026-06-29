import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class CHWTriageScreen extends StatefulWidget {
  final String? patientName;

  const CHWTriageScreen({super.key, this.patientName});

  @override
  State<CHWTriageScreen> createState() => _CHWTriageScreenState();
}

class _CHWTriageScreenState extends State<CHWTriageScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Route args (set in initState)
  String? _ticketId;
  String? _facilityId;
  String? _chwId;
  String _resolvedPatientName = '';

  // Step 1: Patient Info
  final _ageCtrl = TextEditingController();
  String? _selectedGender;

  // Step 2: Vital Signs
  final _temperatureCtrl = TextEditingController();
  final _heartRateCtrl = TextEditingController();
  final _respirationRateCtrl = TextEditingController();
  final _bpCtrl = TextEditingController();

  // Step 3: Symptoms
  final _symptomsCtrl = TextEditingController();
  final Set<String> _selectedSymptoms = {};

  // Results
  String _calculatedPriority = 'medium';
  String _recommendation = 'direct_to_doctor';

  final List<String> _commonSymptoms = [
    'Fever', 'Cough', 'Headache', 'Body Pain', 'Sore Throat',
    'Fatigue', 'Diarrhea', 'Vomiting', 'Shortness of Breath',
    'Chest Pain', 'Dizziness',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadCHWId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _ticketId = args['ticketId']?.toString();
      _facilityId = args['facilityId']?.toString();
      final argName = args['patientName']?.toString();
      _resolvedPatientName = argName ?? widget.patientName ?? '';
    } else {
      _resolvedPatientName = widget.patientName ?? '';
    }
  }

  Future<void> _loadCHWId() async {
    final prefs = await SharedPreferences.getInstance();
    _chwId = prefs.getString('chw_id') ?? '';
    if (_facilityId == null || _facilityId!.isEmpty) {
      _facilityId = prefs.getString('chw_facility_id') ?? '';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ageCtrl.dispose();
    _temperatureCtrl.dispose();
    _heartRateCtrl.dispose();
    _respirationRateCtrl.dispose();
    _bpCtrl.dispose();
    _symptomsCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _calculatePriority() {
    final temp = double.tryParse(_temperatureCtrl.text) ?? 37.0;
    final hr = int.tryParse(_heartRateCtrl.text) ?? 70;
    final rr = int.tryParse(_respirationRateCtrl.text) ?? 16;
    final hasCriticalSymptom = _selectedSymptoms.contains('Chest Pain') ||
        _selectedSymptoms.contains('Shortness of Breath');

    if (temp > 39.5 || hr > 120 || rr > 30 || hasCriticalSymptom) return 'critical';
    if (temp > 38.5 || hr > 100) return 'high';
    if (temp > 37.5) return 'medium';
    return 'low';
  }

  String _determineRecommendation(String priority) {
    if (priority == 'critical') return 'ambulance';
    if (priority == 'high') return 'direct_to_doctor';
    if (_selectedSymptoms.any({'Cough', 'Sore Throat', 'Diarrhea'}.contains)) return 'pharmacy';
    return 'direct_to_doctor';
  }

  Future<void> _submitTriage() async {
    setState(() => _isSubmitting = true);

    try {
      _calculatedPriority = _calculatePriority();
      _recommendation = _determineRecommendation(_calculatedPriority);

      final assessmentId = const Uuid().v4();
      final allSymptoms = [
        ..._selectedSymptoms,
        if (_symptomsCtrl.text.trim().isNotEmpty) _symptomsCtrl.text.trim(),
      ].join(', ');

      // 1. Save assessment to Firestore
      await FirebaseFirestore.instance
          .collection('refugee_queue_system')
          .doc('triage')
          .collection('triage_assessments')
          .doc(assessmentId)
          .set({
        'assessmentId': assessmentId,
        'patientName': _resolvedPatientName,
        'ticketId': _ticketId,
        'facilityId': _facilityId,
        'chwId': _chwId,
        'age': _ageCtrl.text.trim(),
        'gender': _selectedGender,
        'temperature': double.tryParse(_temperatureCtrl.text),
        'heartRate': int.tryParse(_heartRateCtrl.text),
        'respirationRate': int.tryParse(_respirationRateCtrl.text),
        'bloodPressure': _bpCtrl.text.trim(),
        'symptoms': allSymptoms,
        'selectedSymptoms': _selectedSymptoms.toList(),
        'priority': _calculatedPriority,
        'recommendation': _recommendation,
        'assessmentTime': FieldValue.serverTimestamp(),
        'status': 'triaged',
      });

      // 2. Update the Realtime DB ticket if we have a ticketId
      if (_ticketId != null && _ticketId!.isNotEmpty && _facilityId != null && _facilityId!.isNotEmpty) {
        await FirebaseDatabase.instance
            .ref('active_queues/$_facilityId/tickets/$_ticketId')
            .update({
          'priority': _calculatedPriority,
          'triaged': true,
          'triagedAt': ServerValue.timestamp,
          'assessmentId': assessmentId,
        });
      }

      if (!mounted) return;
      _showSuccessDialog();
    } on FirebaseException catch (e) {
      debugPrint('Triage submit Firestore error: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error. Triage not saved: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Triage submit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save triage assessment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    final priorityColor = _priorityColor(_calculatedPriority);
    final recommendationLabel = _recommendationLabel(_recommendation);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Triage Complete',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.15),
                border: Border.all(color: priorityColor, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Priority Level',
                    style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white54),
                  ),
                  Text(
                    _calculatedPriority.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: priorityColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendation',
                    style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white38),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recommendationLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _vitalSummaryRow('Temperature', '${_temperatureCtrl.text}°C'),
            _vitalSummaryRow('Heart Rate', '${_heartRateCtrl.text} bpm'),
            _vitalSummaryRow('Respiration', '${_respirationRateCtrl.text} breaths/min'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetForm();
            },
            child: Text(
              'Assess Another',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/chw_dashboard');
            },
            child: Text(
              'Back to Dashboard',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vitalSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white54)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'critical': return Colors.red;
      case 'high': return Colors.orange;
      case 'medium': return Colors.amber;
      case 'low': return const Color(0xFF10B981);
      default: return Colors.blue;
    }
  }

  String _recommendationLabel(String recommendation) {
    switch (recommendation) {
      case 'ambulance': return 'Call Ambulance — Emergency Transport Required';
      case 'direct_to_doctor': return 'Direct to Doctor — Consultation Needed';
      case 'pharmacy': return 'Pharmacy — Over-the-counter Treatment';
      case 'lab': return 'Laboratory Tests — Further Investigation';
      default: return 'Refer to Doctor';
    }
  }

  void _resetForm() {
    _pageController.jumpToPage(0);
    _ageCtrl.clear();
    _selectedGender = null;
    _temperatureCtrl.clear();
    _heartRateCtrl.clear();
    _respirationRateCtrl.clear();
    _bpCtrl.clear();
    _symptomsCtrl.clear();
    _selectedSymptoms.clear();
    _ticketId = null;
    _resolvedPatientName = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Patient Triage Assessment',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Step progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: Container(
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i <= _currentStep
                          ? const Color(0xFF065F46)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Patient', 'Vitals', 'Symptoms', 'Review'].map((s) {
                final idx = ['Patient', 'Vitals', 'Symptoms', 'Review'].indexOf(s);
                return Text(
                  s,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: idx <= _currentStep
                        ? const Color(0xFF065F46)
                        : Colors.grey[400],
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentStep = i),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPatientInfoStep(),
                _buildVitalSignsStep(),
                _buildSymptomsStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          // Navigation bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Back',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF065F46),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : (_currentStep < 3 ? _nextStep : _submitTriage),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _currentStep < 3 ? 'Next' : 'Submit Assessment',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Information',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          _field(
            label: 'Patient Name',
            controller: TextEditingController(text: _resolvedPatientName),
            hint: 'Patient name',
            enabled: false,
          ),
          const SizedBox(height: 16),
          _field(
            label: 'Age',
            controller: _ageCtrl,
            hint: 'Enter age in years',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Text('Gender', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: ['Male', 'Female', 'Other'].map((g) {
              final selected = _selectedGender == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = g),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF065F46).withOpacity(0.08) : Colors.transparent,
                      border: Border.all(
                        color: selected ? const Color(0xFF065F46) : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      g,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? const Color(0xFF065F46) : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vital Signs', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          _field(label: 'Temperature (°C)', controller: _temperatureCtrl,
              hint: 'e.g. 37.5', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 16),
          _field(label: 'Heart Rate (bpm)', controller: _heartRateCtrl,
              hint: 'e.g. 72', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _field(label: 'Respiration Rate (breaths/min)', controller: _respirationRateCtrl,
              hint: 'e.g. 16', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _field(label: 'Blood Pressure (mmHg)', controller: _bpCtrl, hint: 'e.g. 120/80'),
        ],
      ),
    );
  }

  Widget _buildSymptomsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Symptoms & Complaints',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Select all that apply:',
              style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonSymptoms.map((s) {
              final selected = _selectedSymptoms.contains(s);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) {
                    _selectedSymptoms.remove(s);
                  } else {
                    _selectedSymptoms.add(s);
                  }
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF065F46) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? const Color(0xFF065F46) : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    s,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _field(label: 'Additional Notes', controller: _symptomsCtrl,
              hint: 'Any other symptoms or observations', maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Assessment',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          _reviewCard('Patient Information', [
            ('Name', _resolvedPatientName.isEmpty ? 'Not provided' : _resolvedPatientName),
            ('Age', _ageCtrl.text.isEmpty ? '—' : '${_ageCtrl.text} years'),
            ('Gender', _selectedGender ?? 'Not selected'),
          ]),
          const SizedBox(height: 12),
          _reviewCard('Vital Signs', [
            ('Temperature', _temperatureCtrl.text.isEmpty ? '—' : '${_temperatureCtrl.text}°C'),
            ('Heart Rate', _heartRateCtrl.text.isEmpty ? '—' : '${_heartRateCtrl.text} bpm'),
            ('Respiration', _respirationRateCtrl.text.isEmpty
                ? '—'
                : '${_respirationRateCtrl.text} breaths/min'),
            ('Blood Pressure', _bpCtrl.text.isEmpty ? '—' : _bpCtrl.text),
          ]),
          const SizedBox(height: 12),
          _reviewCard('Symptoms', [
            ('Selected',
                _selectedSymptoms.isEmpty ? 'None selected' : _selectedSymptoms.join(', ')),
            if (_symptomsCtrl.text.trim().isNotEmpty)
              ('Additional Notes', _symptomsCtrl.text.trim()),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF065F46).withOpacity(0.08),
              border: Border.all(color: const Color(0xFF065F46).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Color(0xFF065F46), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap "Submit Assessment" to save this triage and receive priority routing.',
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: const Color(0xFF065F46)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(String title, List<(String, String)> items) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(item.$1,
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: Colors.grey[600])),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.$2,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF065F46), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
