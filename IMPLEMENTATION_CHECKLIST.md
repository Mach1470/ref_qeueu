# Implementation Checklist

This document tracks what has been implemented vs. what needs to be built for the **Mobile Application**. 

*Note: The scope of this mobile application is restricted to the **Refugee** and **Ambulance** roles. Doctor, Pharmacy, and Lab functionalities are managed in the separate Web Application project. The mobile codebase still contains some legacy/initial UI for those roles, which will eventually be migrated/removed.*

## ✅ COMPLETED (Foundation & UI)

### Foundation
- [x] Project setup with Flutter
- [x] Firebase configuration (core, auth, firestore, messaging)
- [x] Basic navigation structure with named routes
- [x] Onboarding screen (3 pages: Welcome, Problem, Solution)
- [x] Role selection screen (Updated to show only Refugee and Ambulance roles)
- [x] All routes defined in `main.dart`

### Authentication
- [x] Refugee login screen (phone OTP + email/ID)
- [x] OTP verification screen
- [x] Basic auth service (mocked & persistent)
- [x] Login persistence using SharedPreferences

### Core Screens (Basic UI)
- [x] Refugee home screen (basic UI, no queue submission yet)
- [x] Ambulance request screen (placeholder)
- [x] Map screen (basic Google Maps)

### Code Quality
- [x] Fixed file naming issues
- [x] Fixed linter errors
- [x] Clean architecture structure
- [x] Custom App Bar & Bottom Navigation components implemented

---

## 💻 MOVED TO WEB APP (Completed or Pending in web scope)

### Pharmacy Module (Fully implemented in mobile codebase, moving to web)
- [x] Pharmacy login screen (`/pharmacy_login`)
- [x] Pharmacy dashboard screen (`/pharmacy_dashboard`)
- [x] Patient detail screen & "Mark as Served" flow
- [x] Pharmacy models (`pharmacy_models.dart`)

### Doctor Module (Moving to web)
- [x] Doctor home screen with patient queue
- [x] Basic patient detail screen (doctor view)
- [ ] Consultation screen with full workflow (WEB Scope)
- [ ] Prescription builder (WEB Scope)
- [ ] Forward to pharmacy/lab (WEB Scope)

### Lab Module (Moving to web)
- [x] Lab home screen (placeholder)
- [ ] Lab dashboard with test requests (WEB Scope)
- [ ] Test result upload (WEB Scope)

---

## 🚧 IN PROGRESS / PARTIAL (Mobile Scope)

### Authentication
- [ ] Firebase Auth integration (currently mocked/local only)
- [ ] Full session management and token validation

### Refugee Module
- [x] Basic home screen UI
- [ ] Queue submission screen (CRITICAL - NOT STARTED)
- [ ] Location-based hospital selection (NOT STARTED)
- [ ] Symptom + image input (NOT STARTED)
- [ ] Queue status tracking (NOT STARTED)
- [ ] Active queue display (NOT STARTED)

### Ambulance Module
- [x] Basic UI screen
- [ ] Real-time location tracking (NOT STARTED)
- [ ] ETA calculation (NOT STARTED)
- [ ] Status updates (NOT STARTED)
- [ ] Driver dashboard (NOT STARTED)

---

## ❌ NOT STARTED (Critical Mobile Features)

### Phase 1: Refugee Queue Submission (HIGHEST PRIORITY)
**Status**: NOT STARTED
**Estimated**: 8-12 hours

- [ ] Create `queue_submission_screen.dart`
- [ ] Implement location service (`geolocator`)
- [ ] Hospital selection with distance calculation
- [ ] Symptom input form
- [ ] Image picker integration
- [ ] Queue submission logic to Firestore
- [ ] Update refugee home screen with active queue status

### Phase 2: Firestore Integration (HIGH PRIORITY)
**Status**: NOT STARTED
**Estimated**: 15-20 hours

- [ ] Firestore setup and configuration confirmation
- [ ] Queue service (Refugee joining lists)
- [ ] Patient service
- [ ] Ambulance service
- [ ] Real-time listeners for wait time / position updates
- [ ] Security rules

### Phase 3: Ambulance Tracking (MEDIUM PRIORITY)
**Status**: NOT STARTED
**Estimated**: 12-15 hours

- [ ] Real-time location updates
- [ ] ETA calculation
- [ ] Status update mechanism
- [ ] Driver dashboard
- [ ] Map integration

---

## 📋 Next Immediate Actions

### Step 1 (IMMEDIATE)
1. **Create Queue Submission Screen** (8-10 hours)
   - This is the CORE feature for refugees.
   - Form for symptoms, images, and hospital selection based on location.

### Step 2 
1. **Firestore Integration for Refugee Flow** (10-15 hours)
   - Link the submission screen to Firestore.
   - Add real-time listeners for queue position on the refugee home screen.

### Step 3
1. **Ambulance Tracking Flow** (10-15 hours)
   - Driver dashboard.
   - Real-time location updates.

---

## 🎯 Priority Order

1. **CRITICAL** (Blocking core functionality):
   - Refugee queue submission
   - Firestore integration for queue joining

2. **HIGH** (Needed for complete workflow):
   - Real-time updates for wait times and queue position

3. **MEDIUM** (Enhancements):
   - Ambulance tracking
   - Notifications

---

## 📊 Progress Summary (Mobile Scope Only)

- **Foundation**: 100% ✅
- **Authentication**: 60% 🚧
- **Refugee Module**: 20% 🚧
- **Ambulance Module**: 10% 🚧
- **Firestore Integration**: 0% ❌
- **Overall (Mobile Scope)**: ~40% Complete

---

**Last Updated**: [Current Date]
**Next Review**: After completing refugee queue submission screen
