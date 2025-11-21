# Firestore Integration Plan - My Queue App

## 🎯 Overview

This document provides a comprehensive, step-by-step plan to integrate Firestore into the My Queue app, making it fully functional with real-time data synchronization.

**Current Status**: Firebase is connected, but Firestore integration is pending.
**Goal**: Full real-time queue management system with all features functional.

---

## 📋 Prerequisites

✅ Firebase project created
✅ `firebase_core` configured
✅ `cloud_firestore` package added to `pubspec.yaml`
✅ `firebase_options.dart` generated
✅ Android and iOS Firebase config files in place

---

## 🏗️ Phase 1: Firestore Setup & Initialization

### Step 1.1: Initialize Firestore in Main App
**File**: `lib/main.dart`
**Time**: 15 minutes

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(const MyApp());
}
```

### Step 1.2: Create Firestore Service Base
**File**: `lib/services/firestore_service.dart`
**Time**: 30 minutes

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get Firestore instance
  static FirebaseFirestore get instance => _firestore;
  
  // Helper method for batch writes
  static WriteBatch batch() => _firestore.batch();
  
  // Helper method for transactions
  static Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) => _firestore.runTransaction(updateFunction);
}
```

---

## 📊 Phase 2: Database Schema Design

### Collections Structure

```
/hospitals/{hospitalId}
  - name: string
  - address: string
  - location: {lat: number, lng: number}
  - departments: [string]
  - capacity: number
  - createdAt: timestamp

/queues/{hospitalId}
  - hospitalId: string
  - hospitalName: string
  - currentNumber: number
  - status: "active" | "paused" | "closed"
  - totalPatients: number
  - estimatedWaitTime: number (minutes)
  - updatedAt: timestamp

/patients/{patientId}
  - name: string
  - age: number
  - phone: string
  - email: string (optional)
  - individualNumber: string (optional)
  - condition: string
  - symptoms: string
  - images: [string] (URLs)
  - queueNumber: number
  - hospitalId: string
  - assignedHospital: string
  - status: "waiting" | "consulting" | "completed" | "cancelled"
  - location: {lat: number, lng: number}
  - createdAt: timestamp
  - updatedAt: timestamp
  - diagnosis: string (optional, added by doctor)
  - prescriptionId: string (optional)
  - labRequestId: string (optional)
  - emergency: boolean

/doctors/{doctorId}
  - name: string
  - email: string
  - phone: string
  - hospitalId: string
  - department: string
  - activePatients: [string] (patient IDs)
  - createdAt: timestamp

/prescriptions/{prescriptionId}
  - patientId: string
  - doctorId: string
  - medicines: [
      {
        name: string,
        dosage: string,
        frequency: string,
        duration: string,
        instructions: string (optional)
      }
    ]
  - prescriptionText: string (optional, if saved as text)
  - status: "pending" | "fulfilled" | "cancelled"
  - createdAt: timestamp
  - fulfilledAt: timestamp (optional)

/queues/pharmacy/{hospitalId}
  - hospitalId: string
  - patients: [string] (patient IDs)
  - currentNumber: number
  - updatedAt: timestamp

/queues/lab/{hospitalId}
  - hospitalId: string
  - requests: [string] (lab request IDs)
  - updatedAt: timestamp

/lab_requests/{requestId}
  - patientId: string
  - doctorId: string
  - hospitalId: string
  - testType: string
  - notes: string (optional)
  - status: "pending" | "in_progress" | "completed"
  - resultUrl: string (optional)
  - resultText: string (optional)
  - createdAt: timestamp
  - completedAt: timestamp (optional)

/ambulance_requests/{requestId}
  - patientId: string
  - location: {lat: number, lng: number}
  - address: string (optional)
  - priority: "low" | "medium" | "high" | "critical"
  - status: "requested" | "dispatched" | "en_route" | "arrived" | "completed" | "cancelled"
  - ambulanceId: string (optional)
  - driverId: string (optional)
  - estimatedArrival: timestamp (optional)
  - createdAt: timestamp
  - updatedAt: timestamp

/ambulances/{ambulanceId}
  - unitNumber: string
  - driverId: string
  - driverName: string
  - location: {lat: number, lng: number}
  - status: "available" | "dispatched" | "on_call"
  - currentRequestId: string (optional)
  - updatedAt: timestamp
```

---

## 🔧 Phase 3: Service Layer Implementation

### Step 3.1: Queue Service
**File**: `lib/services/queue_service.dart`
**Time**: 2-3 hours

**Methods to implement**:
- `addPatientToQueue(String patientId, String hospitalId)`
- `removePatientFromQueue(String patientId, String hospitalId)`
- `getQueue(String hospitalId)` - Stream
- `updateQueuePosition(String hospitalId, int newPosition)`
- `getQueuePosition(String patientId)`
- `getEstimatedWaitTime(String hospitalId)`

### Step 3.2: Patient Service
**File**: `lib/services/patient_service.dart`
**Time**: 2-3 hours

**Methods to implement**:
- `createPatient(Map<String, dynamic> data)`
- `getPatient(String patientId)` - Stream
- `updatePatientStatus(String patientId, String status)`
- `addSymptoms(String patientId, String symptoms, List<String> imageUrls)`
- `updateDiagnosis(String patientId, String diagnosis)`
- `getPatientHistory(String patientId)`

### Step 3.3: Prescription Service
**File**: `lib/services/prescription_service.dart`
**Time**: 2 hours

**Methods to implement**:
- `createPrescription(String patientId, String doctorId, List<Map> medicines)`
- `getPrescription(String prescriptionId)` - Stream
- `forwardToPharmacy(String prescriptionId, String hospitalId)`
- `markPrescriptionFulfilled(String prescriptionId)`
- `getPrescriptionsByPatient(String patientId)`

### Step 3.4: Lab Service
**File**: `lib/services/lab_service.dart`
**Time**: 2 hours

**Methods to implement**:
- `createLabRequest(String patientId, String doctorId, String testType, String? notes)`
- `getLabRequests(String hospitalId)` - Stream
- `uploadLabResult(String requestId, String? resultUrl, String? resultText)`
- `markLabRequestComplete(String requestId)`
- `getLabRequest(String requestId)` - Stream

### Step 3.5: Ambulance Service
**File**: `lib/services/ambulance_service.dart`
**Time**: 2-3 hours

**Methods to implement**:
- `createAmbulanceRequest(String patientId, Map location, String priority)`
- `getAmbulanceRequests()` - Stream
- `assignAmbulance(String requestId, String ambulanceId)`
- `updateAmbulanceLocation(String ambulanceId, Map location)`
- `updateRequestStatus(String requestId, String status)`
- `getAmbulanceLocation(String ambulanceId)` - Stream

### Step 3.6: Hospital Service
**File**: `lib/services/hospital_service.dart`
**Time**: 1-2 hours

**Methods to implement**:
- `getHospitals()` - Stream
- `getHospital(String hospitalId)`
- `findNearestHospitals(double lat, double lng, int limit)`
- `getHospitalQueue(String hospitalId)` - Stream

---

## 🔄 Phase 4: Real-time Listeners

### Step 4.1: Queue Listeners
**Implementation**: Add to `queue_service.dart`

```dart
Stream<QuerySnapshot> listenToQueue(String hospitalId) {
  return FirestoreService.instance
      .collection('queues')
      .doc(hospitalId)
      .collection('patients')
      .orderBy('queueNumber')
      .snapshots();
}

Stream<DocumentSnapshot> listenToQueuePosition(String patientId) {
  return FirestoreService.instance
      .collection('patients')
      .doc(patientId)
      .snapshots();
}
```

### Step 4.2: Patient Status Listeners
**Implementation**: Add to `patient_service.dart`

```dart
Stream<DocumentSnapshot> listenToPatientStatus(String patientId) {
  return FirestoreService.instance
      .collection('patients')
      .doc(patientId)
      .snapshots();
}
```

### Step 4.3: Pharmacy Queue Listeners
**Implementation**: Add to `prescription_service.dart`

```dart
Stream<QuerySnapshot> listenToPharmacyQueue(String hospitalId) {
  return FirestoreService.instance
      .collection('queues')
      .doc('pharmacy')
      .collection(hospitalId)
      .orderBy('queueNumber')
      .snapshots();
}
```

---

## 🔐 Phase 5: Security Rules

### Step 5.1: Create Security Rules
**File**: `firestore.rules` (in Firebase Console)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function getUserRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }
    
    // Hospitals - Read only for authenticated users
    match /hospitals/{hospitalId} {
      allow read: if isAuthenticated();
      allow write: if false; // Only admins can write (add admin check later)
    }
    
    // Queues - Read by hospital staff, write by system
    match /queues/{hospitalId} {
      allow read: if isAuthenticated();
      allow write: if false; // Only through server functions or admin
    }
    
    // Patients - Read own data or hospital staff, write own data
    match /patients/{patientId} {
      allow read: if isAuthenticated() && (
        isOwner(patientId) || 
        resource.data.hospitalId == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.hospitalId
      );
      allow create: if isAuthenticated() && isOwner(patientId);
      allow update: if isAuthenticated() && (
        isOwner(patientId) || 
        getUserRole() == 'doctor'
      );
    }
    
    // Doctors - Read own data or same hospital
    match /doctors/{doctorId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(doctorId) || getUserRole() == 'admin';
    }
    
    // Prescriptions - Read by patient, doctor, or pharmacy
    match /prescriptions/{prescriptionId} {
      allow read: if isAuthenticated() && (
        resource.data.patientId == request.auth.uid ||
        resource.data.doctorId == request.auth.uid ||
        getUserRole() == 'pharmacy'
      );
      allow create: if isAuthenticated() && getUserRole() == 'doctor';
      allow update: if isAuthenticated() && (
        resource.data.doctorId == request.auth.uid ||
        getUserRole() == 'pharmacy'
      );
    }
    
    // Lab Requests - Read by patient, doctor, or lab
    match /lab_requests/{requestId} {
      allow read: if isAuthenticated() && (
        resource.data.patientId == request.auth.uid ||
        resource.data.doctorId == request.auth.uid ||
        getUserRole() == 'lab'
      );
      allow create: if isAuthenticated() && getUserRole() == 'doctor';
      allow update: if isAuthenticated() && (
        resource.data.doctorId == request.auth.uid ||
        getUserRole() == 'lab'
      );
    }
    
    // Ambulance Requests - Read by patient or ambulance staff
    match /ambulance_requests/{requestId} {
      allow read: if isAuthenticated() && (
        resource.data.patientId == request.auth.uid ||
        getUserRole() == 'ambulance' ||
        getUserRole() == 'admin'
      );
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && (
        resource.data.patientId == request.auth.uid ||
        getUserRole() == 'ambulance' ||
        getUserRole() == 'admin'
      );
    }
  }
}
```

---

## 📱 Phase 6: Integration with Screens

### Step 6.1: Refugee Home Screen
**File**: `lib/screens/refugee_home_screen.dart`
**Time**: 2-3 hours

**Changes**:
- Replace mock data with Firestore streams
- Add real-time queue position listener
- Show active queue status
- Add queue submission integration

### Step 6.2: Queue Submission Screen
**File**: `lib/screens/queue_submission_screen.dart` (NEW)
**Time**: 3-4 hours

**Features**:
- Get user location
- Find nearest hospitals from Firestore
- Submit symptoms and images
- Add patient to queue
- Upload images to Firebase Storage first

### Step 6.3: Doctor Home Screen
**File**: `lib/screens/doctor_home_screen.dart`
**Time**: 2-3 hours

**Changes**:
- Replace mock patient list with Firestore stream
- Filter by hospital
- Real-time queue updates
- Add prescription creation integration

### Step 6.4: Pharmacy Dashboard
**File**: `lib/screens/pharmacy/pharmacy_dashboard_screen.dart`
**Time**: 2 hours

**Changes**:
- Replace mock queue with Firestore stream
- Listen to pharmacy queue collection
- Real-time updates when new prescriptions arrive

### Step 6.5: Lab Home Screen
**File**: `lib/screens/lab_home_screen.dart`
**Time**: 2-3 hours

**Changes**:
- Add Firestore stream for lab requests
- Filter by hospital
- Real-time updates

---

## 🖼️ Phase 7: Firebase Storage Integration

### Step 7.1: Image Upload Service
**File**: `lib/services/storage_service.dart`
**Time**: 1-2 hours

```dart
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<String> uploadSymptomImage(File image, String patientId) async {
    final ref = _storage.ref().child('symptoms/$patientId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }
  
  Future<String> uploadLabResult(File file, String requestId) async {
    final ref = _storage.ref().child('lab_results/$requestId/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
```

### Step 7.2: Add Firebase Storage Package
**File**: `pubspec.yaml`

```yaml
dependencies:
  firebase_storage: ^12.0.0
```

---

## 🔔 Phase 8: Push Notifications

### Step 8.1: Notification Service
**File**: `lib/services/notification_service.dart`
**Time**: 2-3 hours

**Features**:
- Queue position updates
- Prescription ready notifications
- Lab result ready notifications
- Ambulance status updates

### Step 8.2: Firebase Cloud Messaging Setup
**Implementation**: Follow Firebase FCM documentation

---

## 📝 Phase 9: Implementation Checklist

### Week 1: Foundation
- [ ] Initialize Firestore in main.dart
- [ ] Create FirestoreService base class
- [ ] Set up security rules (test mode first)
- [ ] Create all service files (empty implementations)

### Week 2: Core Services
- [ ] Implement Queue Service
- [ ] Implement Patient Service
- [ ] Implement Hospital Service
- [ ] Test basic CRUD operations

### Week 3: Advanced Services
- [ ] Implement Prescription Service
- [ ] Implement Lab Service
- [ ] Implement Ambulance Service
- [ ] Add real-time listeners

### Week 4: Integration
- [ ] Integrate with Refugee screens
- [ ] Integrate with Doctor screens
- [ ] Integrate with Pharmacy screens
- [ ] Integrate with Lab screens
- [ ] Add Firebase Storage for images

### Week 5: Testing & Optimization
- [ ] Test all flows end-to-end
- [ ] Optimize queries (add indexes)
- [ ] Test security rules
- [ ] Add error handling
- [ ] Performance testing

---

## 🚨 Important Notes

1. **Start with Test Mode**: Use test security rules initially, then tighten them
2. **Add Indexes**: Firestore will prompt for composite indexes - add them
3. **Error Handling**: Always wrap Firestore calls in try-catch
4. **Offline Support**: Firestore persistence is enabled by default
5. **Batch Operations**: Use batches for multiple writes
6. **Transactions**: Use transactions for critical operations (queue numbers)

---

## 📊 Estimated Timeline

- **Phase 1-2**: 1 day (Setup & Schema)
- **Phase 3**: 3-4 days (Service Layer)
- **Phase 4**: 1 day (Real-time Listeners)
- **Phase 5**: 1 day (Security Rules)
- **Phase 6**: 3-4 days (Screen Integration)
- **Phase 7**: 1 day (Storage)
- **Phase 8**: 1-2 days (Notifications)
- **Phase 9**: 2-3 days (Testing)

**Total**: 13-17 days (2.5-3.5 weeks)

---

## 🎯 Success Criteria

✅ All screens use real Firestore data
✅ Real-time updates work correctly
✅ Queue management is functional
✅ Prescriptions flow from doctor to pharmacy
✅ Lab requests flow from doctor to lab
✅ Ambulance tracking works
✅ Security rules protect data
✅ Images upload successfully
✅ Notifications work
✅ Offline mode works

---

**Last Updated**: [Current Date]
**Status**: Ready for Implementation

