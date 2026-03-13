import 'package:flutter/material.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import '../../models/pharmacy_models.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  // Mock patient ID for testing (replace with actual patient ID logic later)
  final String _patientId = 'P002';
  PatientPrescription? _currentStatus;
  bool _isLoading = true;
  bool _canCall = true; // State to manage the "Call Me Back" button

  @override
  void initState() {
    super.initState();
    _fetchPatientStatus();
  }

  // Mock function to simulate fetching patient status from a database/queue
  void _fetchPatientStatus() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Find the patient's prescription status from the mock data
        try {
          _currentStatus =
              initialPharmacyQueue.firstWhere((p) => p.id == _patientId);
        } catch (e) {
          _currentStatus =
              null; // Patient not found or prescription is completed/archived
        }

        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Function to simulate notifying staff to call the patient back
  void _requestCallback() {
    setState(() {
      _canCall = false; // Disable button immediately
    });

    // In a real app, this would update a field in Firestore
    // (e.g., patient.callbackRequested = true)

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Staff notified! They will call you to the counter soon.')),
    );

    // Re-enable the button after a cool-down period
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          _canCall = true;
        });
      }
    });
  }

  // Helper to get color based on status
  Color _getStatusColor(PharmacyServiceStatus? status) {
    switch (status) {
      case PharmacyServiceStatus.pending:
        return Colors.grey.shade600;
      case PharmacyServiceStatus.inQueue:
        return Colors.orange.shade600;
      case PharmacyServiceStatus.inService:
        return Colors.blue.shade600;
      case PharmacyServiceStatus.completed:
        return Colors.green.shade600;
      default:
        return Colors.grey.shade400;
    }
  }

  // Helper to get icon based on status
  IconData _getStatusIcon(PharmacyServiceStatus? status) {
    switch (status) {
      case PharmacyServiceStatus.pending:
        return Icons.access_time;
      case PharmacyServiceStatus.inQueue:
        return Icons.list_alt;
      case PharmacyServiceStatus.inService:
        return Icons.local_pharmacy;
      case PharmacyServiceStatus.completed:
        return Icons.check_circle;
      default:
        return Icons.error_outline;
    }
  }

  // Widget to display the patient status card
  Widget _buildStatusCard() {
    final status = _currentStatus?.serviceStatus;
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);

    String title = 'Status Not Found';
    String message =
        'Please ensure you entered the correct ID or contact staff.';

    if (status != null) {
      switch (status) {
        case PharmacyServiceStatus.pending:
          title = 'Processing Prescription...';
          message =
              'Your prescription is currently being reviewed by the medical team.';
          break;
        case PharmacyServiceStatus.inQueue:
          title = 'In Pharmacy Queue';
          message =
              'Your prescription is ready to be filled. Please wait for your ID ($_patientId) to be called.';
          break;
        case PharmacyServiceStatus.inService:
          title = 'Prescription Being Prepared';
          message =
              'Your medications are actively being prepared at counter ${_currentStatus!.serviceCounter}.';
          break;
        case PharmacyServiceStatus.completed:
          title = 'Ready for Pickup!';
          message =
              'Your prescription is complete. Proceed to counter ${_currentStatus!.serviceCounter}.';
          break;
        case PharmacyServiceStatus.cancelled:
          title = 'Prescription Cancelled';
          message = 'The order has been cancelled. Please speak to a nurse.';
          break;
      }
    }

    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: color),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your ID: $_patientId',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500),
            ),
            const Divider(height: 30),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),

            // "Call Me Back" button only visible when in queue and not completed
            if (status == PharmacyServiceStatus.inQueue)
              ElevatedButton.icon(
                onPressed: _canCall ? _requestCallback : null,
                icon: const Icon(Icons.phone_in_talk),
                label: Text(_canCall
                    ? 'Request Counter Call'
                    : 'Request Sent. Please wait...'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canCall ? Colors.red.shade600 : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      appBar: AppBar(
        title: const Text('My Pharmacy Status'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          // Logout/Switch Role Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/auth/refugee_login', (route) => false),
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 16),
                  Text('Fetching status...', style: TextStyle(fontSize: 18)),
                ],
              )
            : _buildStatusCard(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchPatientStatus,
        backgroundColor: Colors.blue.shade500,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
