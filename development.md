# Refugee Health Queue App - Development Guide

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Current Status](#current-status)
3. [Architecture](#architecture)
4. [Development Phases](#development-phases)
5. [Code Quality & Standards](#code-quality--standards)
6. [Firestore Integration Plan](#firestore-integration-plan)
7. [Testing Strategy](#testing-strategy)
8. [Deployment Checklist](#deployment-checklist)

---

## 🎯 Project Overview

**Refugee Health Queue App** is a multi-role health service queue management system designed for refugee camps. It replaces physical queues with a virtual queueing system, allowing refugees to access health services without waiting under the sun.

### Core Problem
Refugees spend hours in physical queues, unsure when they'll be served. This app provides:
- Virtual queue management
- Real-time status updates
- Multi-role dashboards (Refugee, Doctor, Pharmacy, Lab, Ambulance)
- Location-based hospital assignment
- Prescription and lab result management

### Target Users
1. **Refugees** - Submit symptoms, join queues, track status
2. **Doctors** - View queues, diagnose, prescribe, refer
3. **Pharmacy** - View prescriptions, issue medicine
4. **Lab Technicians** - Receive test requests, upload results
5. **Ambulance Services** - Handle emergency requests with live tracking

---

## 📊 Current Status

### ✅ Completed Features

#### Phase 0: Foundation (COMPLETE)
- [x] Project setup with Flutter
- [x] Firebase configuration (core, auth, firestore, messaging)
- [x] Basic navigation structure
- [x] Onboarding screen with 3 pages
- [x] Role selection screen with animated grid
- [x] Basic routing system

#### Phase 1: Authentication (PARTIAL)
- [x] Refugee login screen (phone OTP + email/ID)
- [x] OTP verification screen
- [x] Basic auth service (mocked)
- [x] Pharmacy login screen
- [ ] Firebase Auth integration (TODO)
- [ ] Role-based authentication (TODO)

#### Phase 2: Core Screens (PARTIAL)
- [x] Refugee home screen (basic UI)
- [x] Doctor home screen with patient queue
- [x] Patient detail screen (doctor view)
- [x] Pharmacy dashboard
- [x] Pharmacy patient detail screen
- [x] Lab home screen (placeholder)
- [x] Ambulance request screen (placeholder)
- [x] Map screen (basic Google Maps)

#### Phase 3: Data Models (PARTIAL)
- [x] Patient model (doctor view)
- [x] Patient model (pharmacy view)
- [x] Medicine model
- [ ] Queue model (TODO)
- [ ] Hospital model (TODO)
- [ ] Prescription model (TODO)

### ⚠️ Issues Found & Status

1. ✅ **FIXED**: Missing file `pharmacy_patient_detail_screen.dart` - Created correctly
2. ✅ **FIXED**: Linter errors in `role_selection_screen.dart` - Removed unused import and field
3. ⚠️ **REMAINING**: Model Duplication - Two different `Patient` models (one in `models/patient.dart`, one in `pharmacy/pharmacy_models.dart`)
4. **Incomplete Features**:
   - Refugee queue submission not implemented
   - Doctor prescription flow incomplete
   - Lab workflow missing
   - Ambulance tracking not functional
   - Firestore integration pending

---

## 🏗️ Architecture

### Directory Structure
```
lib/
├── main.dart                    # App entry, routing
├── firebase_options.dart        # Firebase config
├── models/                      # Data models
│   ├── patient.dart            # Patient model (doctor view)
│   └── medicine.dart           # Medicine model
├── screens/                     # All UI screens
│   ├── onboarding_screen.dart
│   ├── role_selection_screen.dart
│   ├── auth/                    # Authentication screens
│   │   ├── refugee_login_screen.dart
│   │   ├── otp_verification_screen.dart
│   │   └── refugee_signup_screen.dart
│   ├── refugee_home_screen.dart
│   ├── doctor_home_screen.dart
│   ├── patient_detail_screen.dart
│   ├── lab_home_screen.dart
│   ├── ambulance_request_screen.dart
│   ├── map_screen.dart
│   └── pharmacy/                # Pharmacy module
│       ├── pharmacy_login_screen.dart
│       ├── pharmacy_dashboard_screen.dart
│       ├── pharmacy_patient_detail_screen.dart
│       └── pharmacy_models.dart
├── services/                    # Business logic
│   └── auth_service.dart        # Authentication (mocked)
└── widgets/                     # Reusable widgets
    ├── bottom_nav.dart
    └── custom_app_bar.dart
```

### Navigation Flow

**Primary Routes** (defined in `main.dart`):
- `/onboarding` → OnboardingScreen
- `/` → RoleSelectionScreen
- `/auth/refugee` → RefugeeLoginScreen
- `/refugee_home` → RefugeeHomeScreen
- `/doctor` → DoctorHomeScreen
- `/lab` → LabHomeScreen
- `/pharmacy_login` → PharmacyLoginScreen
- `/pharmacy_dashboard` → PharmacyDashboardScreen
- `/ambulance` → AmbulanceRequestScreen

**Role Selection Navigation**:
- Refugee → `/auth/refugee`
- Doctor → `/doctor`
- Lab → `/lab`
- Pharmacy → `/pharmacy_login`
- Ambulance → `/ambulance`

**Complete Flow**:
```
Onboarding → Role Selection → [Role-Specific Screen]
                                    │
                    ┌───────────────┼───────────────┬───────────────┐
                    │               │               │               │
              Refugee Login    Doctor Home    Pharmacy Login    Lab Home
                    │               │               │               │
              Refugee Home    Patient Detail  Pharmacy Dash    (TODO)
                    │               │               │
              Queue Submit    Consultation    Patient Detail
                    │               │               │
              (Join Queue)    (Prescribe)    (Mark Served)
                                    │
                            Forward to Pharmacy/Lab
```

### State Management
- **Current**: Local state (StatefulWidget)
- **Recommended**: Provider or Riverpod for complex state
- **Future**: Consider BLoC for larger features

---

## 🚀 Development Phases

### Phase 1: Fix Current Issues (IMMEDIATE)
**Priority: HIGH | Estimated: 2-4 hours**

1. ✅ **COMPLETED**: Fix File Naming
   - ✅ Renamed `pharmacy_patient_detail_screen 2.dart` → `pharmacy_patient_detail_screen.dart`
   - ✅ Updated imports in `pharmacy_dashboard_screen.dart`

2. ✅ **COMPLETED**: Fix Linter Errors
   - ✅ Removed unused import `package:flutter/foundation.dart` in `role_selection_screen.dart`
   - ✅ Removed unused `_stagger` field

3. **Unify Patient Models** (REMAINING)
   - Create single `Patient` model that works for all roles
   - Add optional fields for role-specific data
   - Update all references
   - **Location**: `lib/models/patient.dart` (unified model)
   - **Impact**: Affects `pharmacy/pharmacy_models.dart` and `models/patient.dart`

4. **Code Cleanup**
   - Remove duplicate code
   - Standardize naming conventions
   - Add missing documentation

---

### Phase 2: Refugee Queue Submission (HIGH PRIORITY)
**Priority: HIGH | Estimated: 8-12 hours**

**Core Flow**: Refugee logs in → selects nearest hospital → submits symptoms + optional images → joins queue

#### 2.1 Queue Submission Screen
- [ ] Create `queue_submission_screen.dart`
- [ ] Hospital selection (nearest based on location)
  - Display list of hospitals sorted by distance
  - Show distance for each hospital
  - Allow manual hospital selection
- [ ] Symptom input (text + optional images)
  - Multi-line text field for symptoms description
  - Image picker for up to 3-5 images
  - Preview selected images before submission
- [ ] Image picker integration
  - Use `image_picker` package
  - Support camera and gallery
  - Compress images before upload
- [ ] Submit to queue (mock for now, Firestore later)
  - Validate inputs
  - Show loading state
  - Display success message
  - Navigate back to refugee home with queue status

#### 2.2 Location Services
- [ ] Integrate `geolocator` properly
  - Request location permissions (Android & iOS)
  - Handle permission denied gracefully
  - Show permission explanation dialog
- [ ] Find nearest hospital
  - Calculate distance from user location to each hospital
  - Sort hospitals by distance
  - Store hospital coordinates (mock data for now)
- [ ] Display hospital list with distances
  - Show hospital name, address, distance
  - Highlight nearest hospital
  - Allow selection
- [ ] Create `location_service.dart`
  - `getCurrentLocation()` method
  - `calculateDistance()` method
  - `findNearestHospitals()` method

#### 2.3 Queue Status Tracking
- [ ] Display current queue position
- [ ] Estimated wait time
- [ ] Push notifications when queue advances
- [ ] Cancel queue option

#### 2.4 Refugee Home Screen Enhancements
- [ ] Active queue card (if in queue)
- [ ] Queue history
- [ ] Medical history section
- [ ] Profile management

**Files to Create/Modify:**
- `lib/screens/queue_submission_screen.dart`
- `lib/services/location_service.dart`
- `lib/services/queue_service.dart` (mocked)
- Update `lib/screens/refugee_home_screen.dart`

---

### Phase 3: Doctor Prescription Flow (HIGH PRIORITY)
**Priority: HIGH | Estimated: 10-15 hours**

**Core Flow**: Doctor sees queue → chooses a patient → adds diagnosis & prescription → sends to lab or pharmacy

#### 3.1 Consultation Screen (Update `patient_detail_screen.dart`)
- [ ] Full patient history view
  - Display patient info (name, age, condition)
  - Show symptoms text
  - Display symptom images (if any)
  - Show queue number and status
- [ ] Symptom images display
  - Grid view of uploaded images
  - Full-screen image viewer on tap
  - Image zoom functionality
- [ ] Diagnosis input form
  - Multi-line text field for diagnosis
  - Save diagnosis to patient record
- [ ] Prescription builder
  - Add/remove medicines
  - Medicine name, dosage, frequency
  - Instructions field
  - Save as structured data OR plain text
- [ ] Lab test request form
  - Select test type from dropdown
  - Add notes/instructions
  - Submit lab request

#### 3.2 Prescription Management
- [ ] Add/remove medicines
  - Search medicine from database/list
  - Add custom medicine if not found
  - Remove medicine from list
- [ ] Dosage and frequency
  - Dosage: e.g., "500mg", "10ml"
  - Frequency: e.g., "Twice daily", "After meals"
  - Duration: e.g., "5 days", "1 week"
- [ ] Save prescription (text or structured)
  - Option 1: Save as plain text (for paper script scenario)
  - Option 2: Save as structured data (for digital prescription)
  - Store in patient record
- [ ] Forward to pharmacy or lab
  - Button: "Send to Pharmacy" (if prescription added)
  - Button: "Send to Lab" (if lab test requested)
  - Update patient status
  - Add to pharmacy/lab queue

#### 3.3 Patient Actions
- [ ] Mark consultation complete
- [ ] Refer to specialist
- [ ] Request ambulance
- [ ] Schedule follow-up

**Files to Create/Modify:**
- `lib/screens/consultation_screen.dart`
- `lib/screens/prescription_builder_screen.dart`
- `lib/models/prescription.dart`
- Update `lib/screens/patient_detail_screen.dart`
- Update `lib/screens/doctor_home_screen.dart`

---

### Phase 4: Lab Module (MEDIUM PRIORITY)
**Priority: MEDIUM | Estimated: 8-10 hours**

**Core Flow**: Lab receives test requests → uploads results → marks complete → notifies doctor and patient

#### 4.1 Lab Dashboard
- [ ] List of pending test requests
  - Show patient name, test type, requested date
  - Display priority (if emergency)
  - Show doctor who requested
- [ ] Filter by test type
  - Blood tests, X-ray, Ultrasound, etc.
  - Filter by status (pending, in-progress, completed)
- [ ] Priority indicators
  - Emergency tests highlighted
  - Color coding (red for urgent)
- [ ] Test request details
  - Tap to view full request details
  - Show patient info, test type, doctor notes

#### 4.2 Test Result Upload
- [ ] File/image upload for results
  - Upload PDF/image files
  - Support multiple file types
  - Preview before upload
- [ ] Text input for results
  - Text field for result summary
  - Structured data input (if applicable)
- [ ] Mark test as complete
  - Update status to "completed"
  - Save completion timestamp
- [ ] Notify doctor and patient
  - Push notification to doctor
  - Push notification to patient
  - Update patient record

#### 4.3 Lab Models
- [ ] TestRequest model
  ```dart
  class TestRequest {
    final String id;
    final String patientId;
    final String doctorId;
    final String testType;
    final String? notes;
    final DateTime requestedAt;
    final String status; // "pending" | "in_progress" | "completed"
  }
  ```
- [ ] TestResult model
  ```dart
  class TestResult {
    final String requestId;
    final String? resultUrl; // File/image URL
    final String? resultText; // Text summary
    final DateTime completedAt;
  }
  ```
- [ ] Test types enum
  ```dart
  enum TestType {
    bloodTest,
    xray,
    ultrasound,
    ecg,
    // ... more types
  }
  ```

**Files to Create/Modify:**
- `lib/screens/lab_home_screen.dart` (complete implementation)
- `lib/screens/lab_test_detail_screen.dart`
- `lib/screens/lab_result_upload_screen.dart`
- `lib/models/test_request.dart`
- `lib/models/test_result.dart`

---

### Phase 5: Ambulance Tracking (MEDIUM PRIORITY)
**Priority: MEDIUM | Estimated: 12-15 hours**

#### 5.1 Ambulance Request Flow
- [ ] Emergency request form
- [ ] Location capture
- [ ] Priority level selection
- [ ] Request submission

#### 5.2 Live Tracking
- [ ] Real-time ambulance location on map
- [ ] ETA calculation
- [ ] Driver/paramedic info
- [ ] Status updates (dispatched, en route, arrived)

#### 5.3 Ambulance Dashboard (for drivers)
- [ ] Active requests list
- [ ] Navigation integration
- [ ] Mark status updates
- [ ] Patient pickup confirmation

**Files to Create/Modify:**
- `lib/screens/ambulance_request_screen.dart` (complete)
- `lib/screens/ambulance_tracking_screen.dart`
- `lib/screens/ambulance_driver_dashboard.dart`
- `lib/services/ambulance_service.dart`
- `lib/models/ambulance_request.dart`
- Update `lib/screens/map_screen.dart`

---

### Phase 6: Firestore Integration (HIGH PRIORITY)
**Priority: HIGH | Estimated: 20-30 hours**

#### 6.1 Database Schema Design

**Refugee Firestore Behaviors:**
- Store patient symptoms, images, location-hospital mapping
- Add patient to queue collection where `nearest_facility == assigned_hospital`
- Update queue position in real-time
- Track queue status (waiting, consulting, completed)

**Doctor Firestore Behaviors:**
- Read queue where `doctor_hospital == patient_hospital`
- Update patient document with diagnosis and prescription
- Forward to pharmacy or lab (add to respective queues)
- Mark consultation as complete
- Update patient status

**Pharmacy Firestore Behaviors:**
- Listen to collection: `/queues/pharmacy/{hospital}/patients`
- Read prescription from patient document
- Update status to `served` when medicine issued
- Remove from pharmacy queue

**Lab Firestore Behaviors:**
- Receive lab requests from doctor
- Upload test results (images/files or text)
- Mark test as completed
- Notify doctor and patient

```javascript
// Collections structure
/queues/{hospitalId}/
  - patients: [patientId1, patientId2, ...]
  - currentNumber: number
  - status: "active" | "paused"
  - hospitalName: string
  - location: {lat, lng}

/queues/pharmacy/{hospitalId}/
  - patients: [patientId1, patientId2, ...]
  - currentNumber: number

/queues/lab/{hospitalId}/
  - requests: [requestId1, requestId2, ...]

/patients/{patientId}
  - name: string
  - age: number
  - condition: string
  - queueNumber: number
  - status: "waiting" | "consulting" | "completed"
  - hospitalId: string
  - assignedHospital: string  // nearest facility
  - symptoms: string
  - images: [url1, url2, ...]
  - location: {lat, lng}  // refugee location
  - createdAt: timestamp
  - diagnosis: string | null
  - prescriptionId: string | null
  - labRequestId: string | null

/doctors/{doctorId}
  - name: string
  - hospitalId: string
  - department: string
  - activePatients: [patientId1, ...]

/prescriptions/{prescriptionId}
  - patientId: string
  - doctorId: string
  - medicines: [{name, dosage, frequency, duration}]
  - prescriptionText: string | null  // if saved as text
  - createdAt: timestamp
  - status: "pending" | "fulfilled"
  - forwardedToPharmacy: boolean

/lab_requests/{requestId}
  - patientId: string
  - doctorId: string
  - testType: string
  - notes: string | null
  - status: "pending" | "completed"
  - resultUrl: string | null
  - resultText: string | null
  - createdAt: timestamp
  - completedAt: timestamp | null

/ambulance_requests/{requestId}
  - patientId: string
  - location: {lat, lng}
  - status: "requested" | "dispatched" | "en_route" | "arrived"
  - ambulanceId: string | null
  - driverId: string | null
  - estimatedArrival: timestamp | null
  - createdAt: timestamp

/hospitals/{hospitalId}
  - name: string
  - address: string
  - location: {lat, lng}
  - departments: [string]
  - capacity: number
```

#### 6.2 Service Layer
- [ ] `queue_service.dart` - Queue CRUD operations
- [ ] `patient_service.dart` - Patient management
- [ ] `prescription_service.dart` - Prescription handling
- [ ] `lab_service.dart` - Lab request/result management
- [ ] `ambulance_service.dart` - Ambulance tracking
- [ ] `notification_service.dart` - Push notifications

#### 6.3 Real-time Listeners
- [ ] Queue position updates
- [ ] New patient notifications (doctor)
- [ ] Prescription ready (pharmacy)
- [ ] Test results ready (doctor, patient)
- [ ] Ambulance status updates

#### 6.4 Security Rules
- [ ] Role-based access control
- [ ] Data validation rules
- [ ] Hospital isolation
- [ ] Patient privacy rules

**Files to Create:**
- `lib/services/queue_service.dart`
- `lib/services/patient_service.dart`
- `lib/services/prescription_service.dart`
- `lib/services/lab_service.dart`
- `lib/services/ambulance_service.dart`
- `lib/services/notification_service.dart`
- `lib/repositories/` (optional, for clean architecture)

---

### Phase 7: Enhanced Features (LOW PRIORITY)
**Priority: LOW | Estimated: 15-20 hours**

#### 7.1 Notifications
- [ ] Firebase Cloud Messaging setup
- [ ] Queue position updates
- [ ] Prescription ready alerts
- [ ] Test result notifications
- [ ] Ambulance arrival alerts

#### 7.2 Profile Management
- [ ] User profile screen
- [ ] Edit personal info
- [ ] Medical history view
- [ ] Upload ID documents
- [ ] Change password

#### 7.3 Analytics & Reporting
- [ ] Queue statistics (admin)
- [ ] Patient flow analytics
- [ ] Doctor performance metrics
- [ ] Hospital capacity tracking

#### 7.4 Multi-language Support
- [ ] i18n setup
- [ ] English, Arabic, Swahili translations
- [ ] RTL support for Arabic

---

## 📐 Code Quality & Standards

### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `UPPER_SNAKE_CASE`
- **Private members**: `_leadingUnderscore`

### Code Organization
1. **Imports**: Group by package, then local
   ```dart
   // Flutter packages
   import 'package:flutter/material.dart';
   
   // Third-party packages
   import 'package:provider/provider.dart';
   
   // Local imports
   import '../models/patient.dart';
   ```

2. **Widget Structure**:
   ```dart
   class MyWidget extends StatefulWidget {
     // Constructor
     // Build method
     // Private helper methods
   }
   ```

3. **State Management**:
   - Use `StatefulWidget` for simple local state
   - Use `Provider` for shared state
   - Keep business logic in services

### Best Practices
- ✅ Use `const` constructors where possible
- ✅ Extract reusable widgets
- ✅ Handle errors gracefully
- ✅ Add loading states
- ✅ Validate user input
- ✅ Use meaningful variable names
- ✅ Add comments for complex logic
- ✅ Keep widgets small and focused
- ✅ Use `Expanded`/`Flexible` to prevent overflow
- ✅ Test on multiple screen sizes

### Error Handling
```dart
try {
  // Operation
} catch (e) {
  // Log error
  // Show user-friendly message
  // Handle gracefully
}
```

---

## 🔥 Firestore Integration Plan

### Step 1: Setup (2 hours)
1. Configure Firestore in Firebase Console
2. Set up security rules (development mode first)
3. Initialize Firestore in app
4. Test connection

### Step 2: Models to Firestore (4 hours)
1. Convert models to/from Firestore documents
2. Create serialization methods
3. Handle nullable fields
4. Add timestamps

### Step 3: Queue Service (6 hours)
1. Create queue documents
2. Add patient to queue
3. Update queue position
4. Real-time queue listener
5. Remove from queue

### Step 4: Patient Service (4 hours)
1. Create patient document
2. Update patient status
3. Add symptoms/images
4. Link to queue

### Step 5: Prescription Service (4 hours)
1. Create prescription document
2. Link to patient
3. Update pharmacy queue
4. Mark as fulfilled

### Step 6: Lab Service (4 hours)
1. Create lab request
2. Upload results
3. Notify doctor/patient
4. Mark as complete

### Step 7: Ambulance Service (6 hours)
1. Create request
2. Assign ambulance
3. Update location (real-time)
4. Update status

### Step 8: Security Rules (4 hours)
1. Define role-based access
2. Hospital isolation
3. Patient privacy
4. Test thoroughly

---

## 🧪 Testing Strategy

### Unit Tests
- [ ] Service layer tests
- [ ] Model serialization tests
- [ ] Utility function tests

### Widget Tests
- [ ] Screen rendering tests
- [ ] User interaction tests
- [ ] Navigation tests

### Integration Tests
- [ ] Complete user flows
- [ ] Multi-role interactions
- [ ] Firestore operations

### Manual Testing Checklist
- [ ] All screens render correctly
- [ ] Navigation works
- [ ] Forms validate input
- [ ] Error states handled
- [ ] Loading states shown
- [ ] Responsive on different screen sizes
- [ ] Works offline (with Firestore)

---

## 🚢 Deployment Checklist

### Pre-Deployment
- [ ] All features tested
- [ ] No linter errors
- [ ] Security rules configured
- [ ] API keys secured
- [ ] Error tracking setup (Sentry, etc.)
- [ ] Analytics configured
- [ ] App icons and splash screens
- [ ] Version number updated

### Android
- [ ] Signing key configured
- [ ] ProGuard rules (if enabled)
- [ ] Permissions in AndroidManifest.xml
- [ ] Google Maps API key added
- [ ] Firebase config updated
- [ ] Build APK/AAB
- [ ] Test on physical devices

### iOS
- [ ] Signing certificates configured
- [ ] Info.plist permissions
- [ ] Google Maps API key added
- [ ] Firebase config updated
- [ ] Build IPA
- [ ] Test on physical devices

### Post-Deployment
- [ ] Monitor crash reports
- [ ] Track user analytics
- [ ] Gather user feedback
- [ ] Plan updates

---

## 📝 Next Steps (Recommended Order)

### IMMEDIATE (This Week):
1. ✅ Fix file naming and linter errors (COMPLETED)
2. **Unify Patient models** - Create single model for all roles
3. **Complete refugee queue submission** - Core feature for refugees

### SHORT TERM (Next 2 Weeks):
1. **Complete doctor prescription flow** - Diagnosis, prescription, lab requests
2. **Implement lab module** - Test requests, result uploads
3. **Start Firestore integration** - Begin with queue and patient collections

### MEDIUM TERM (Next Month):
1. **Complete Firestore integration** - All collections and real-time listeners
2. **Implement ambulance tracking** - Real-time location updates
3. **Add notifications** - Push notifications for queue updates

### LONG TERM (Future):
1. Enhanced features (analytics, reporting)
2. Multi-language support (English, Arabic, Swahili)
3. Offline support with Firestore persistence
4. Admin dashboard for hospital management

---

## 🎯 What Needs to Be Generated Next

Based on the original specification, the following should be prioritized:

### 1. Refugee Home Screen - Queue Submission (HIGHEST PRIORITY)
**Why**: Core feature - refugees need to submit symptoms and join queues
- Queue submission screen
- Location-based hospital selection
- Symptom + image input
- Queue status tracking

### 2. Doctor Dashboard - Prescription Flow (HIGH PRIORITY)
**Why**: Doctors need to diagnose and prescribe
- Enhanced patient detail screen with consultation
- Prescription builder
- Lab test request form
- Forward to pharmacy/lab functionality

### 3. Lab Module (MEDIUM PRIORITY)
**Why**: Complete the healthcare workflow
- Lab dashboard with test requests
- Result upload functionality
- Status updates

### 4. Ambulance Tracking (MEDIUM PRIORITY)
**Why**: Critical for emergencies
- Real-time location tracking
- Status updates
- ETA calculations

---

## 🛠️ Tools & Resources

### Development Tools
- Flutter SDK (latest stable)
- Android Studio / VS Code
- Firebase Console
- Postman (for API testing)

### Packages Used
- `firebase_core`, `firebase_auth`, `cloud_firestore`
- `google_maps_flutter`, `geolocator`
- `provider` (for state management)
- `google_fonts`, `lottie`

### Documentation
- [Flutter Docs](https://flutter.dev/docs)
- [Firebase Docs](https://firebase.google.com/docs)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)

---

## 📞 Support & Questions

For questions or issues:
1. Check this development guide
2. Review code comments
3. Consult Flutter/Firebase documentation
4. Test in isolation before asking for help

---

---

## 📚 Pharmacy Module - Detailed Specification

### Current Status: ✅ IMPLEMENTED

The pharmacy module is **fully implemented** according to the original specification:

#### 1. Pharmacy Login Screen (`lib/screens/pharmacy/pharmacy_login_screen.dart`)
- ✅ Pharmacy ID input
- ✅ Password input
- ✅ Simple login → navigates to `/pharmacy_dashboard`
- ⚠️ Firestore login will be added later (currently mocked)

#### 2. Pharmacy Dashboard Screen (`lib/screens/pharmacy/pharmacy_dashboard_screen.dart`)
- ✅ Displays list of patients forwarded from doctor
- ✅ Each item shows:
  - Patient photo (or placeholder)
  - Patient name
  - Condition
  - Prescription badge (green) OR "Ask for paper script" (orange)
  - Queue number (#3, #5, etc.)
- ✅ Tap → opens patient detail page
- ✅ Overview metrics at top (queue count, pending prescriptions)
- ✅ Clean UI with spacing, shadow, modern cards

#### 3. Patient Detail Screen (`lib/screens/pharmacy/pharmacy_patient_detail_screen.dart`)
- ✅ Shows patient name & photo
- ✅ Shows condition
- ✅ Shows prescription text (if doctor typed in system)
- ✅ OR orange card telling pharmacist to ask for paper script
- ✅ Button: "Mark as Served"
- ✅ When pressed: Removes patient from queue, sends callback to dashboard

#### 4. Pharmacy Models (`lib/screens/pharmacy/pharmacy_models.dart`)
- ✅ Defines Patient model with:
  - `id`, `name`, `condition`
  - `prescriptionText` (optional)
  - `photoUrl` (optional)
  - `queueNumber` (optional)
  - `served` (boolean)

### Pharmacy Workflow (As Specified)
1. Pharmacy logs in with ID and password
2. Views dashboard with queued patients
3. Taps patient to see details
4. Views prescription (digital or asks for paper)
5. Issues medicine
6. Marks as served (removes from queue)

### Next Steps for Pharmacy Module
- [ ] Integrate with Firestore (listen to `/queues/pharmacy/{hospital}/patients`)
- [ ] Add search/filter functionality
- [ ] Add prescription history
- [ ] Add statistics dashboard
- [ ] Real-time queue updates

---

## 🎨 UI/UX Requirements (From Original Spec)

### Design Principles
- **Responsive UI**: Works on all screen sizes
- **Avoid Row overflow errors**: Use `Expanded` correctly
- **Clean and modern**: Professional healthcare app appearance
- **Consistent theming**: Teal color scheme throughout
- **Accessible**: Clear labels, good contrast

### Role Selection Screen Requirements
- ✅ Grid layout with animations
- ✅ All role cards are tappable
- ✅ Navigation works correctly
- ✅ Responsive (adapts to screen size)

### Navigation Requirements
- ✅ All routes defined in `main.dart`
- ✅ Named routes for consistency
- ✅ Navigation works everywhere
- ✅ Back button works correctly

---

**Last Updated**: [Current Date]
**Version**: 1.0.0
**Status**: In Development

