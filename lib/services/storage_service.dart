import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// Service for handling Firebase Storage operations
/// Supports uploading symptom images, lab results, and documents
class StorageService {
  StorageService._privateConstructor();
  static final StorageService instance = StorageService._privateConstructor();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ---------------------------------------------------------------------------
  // SYMPTOM IMAGES
  // ---------------------------------------------------------------------------

  /// Upload a symptom image for a patient
  /// Returns the download URL on success
  Future<String?> uploadSymptomImage({
    required String patientId,
    required File imageFile,
    String? description,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'symptom_$timestamp${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('symptoms/$patientId/$fileName');

      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'patientId': patientId,
          'uploadedAt': DateTime.now().toIso8601String(),
          if (description != null) 'description': description,
        },
      );

      await ref.putFile(imageFile, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading symptom image: $e');
      return null;
    }
  }

  /// Upload multiple symptom images
  Future<List<String>> uploadSymptomImages({
    required String patientId,
    required List<File> imageFiles,
  }) async {
    final urls = <String>[];

    for (final file in imageFiles) {
      final url = await uploadSymptomImage(
        patientId: patientId,
        imageFile: file,
      );
      if (url != null) {
        urls.add(url);
      }
    }

    return urls;
  }

  // ---------------------------------------------------------------------------
  // LAB RESULTS
  // ---------------------------------------------------------------------------

  /// Upload a lab result file (image or PDF)
  Future<String?> uploadLabResult({
    required String requestId,
    required File resultFile,
    String? testType,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(resultFile.path);
      final fileName = 'result_$timestamp$extension';
      final ref = _storage.ref().child('lab_results/$requestId/$fileName');

      // Determine content type
      String contentType = 'application/octet-stream';
      if (extension.toLowerCase() == '.pdf') {
        contentType = 'application/pdf';
      } else if (['.jpg', '.jpeg', '.png'].contains(extension.toLowerCase())) {
        contentType = 'image/${extension.substring(1).toLowerCase()}';
      }

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'requestId': requestId,
          'uploadedAt': DateTime.now().toIso8601String(),
          if (testType != null) 'testType': testType,
        },
      );

      await ref.putFile(resultFile, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading lab result: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // PRESCRIPTIONS
  // ---------------------------------------------------------------------------

  /// Upload a prescription image or PDF
  Future<String?> uploadPrescription({
    required String prescriptionId,
    required File file,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.path);
      final fileName = 'prescription_$timestamp$extension';
      final ref =
          _storage.ref().child('prescriptions/$prescriptionId/$fileName');

      final metadata = SettableMetadata(
        customMetadata: {
          'prescriptionId': prescriptionId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      await ref.putFile(file, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading prescription: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // PROFILE PHOTOS
  // ---------------------------------------------------------------------------

  /// Upload a profile photo for a user
  Future<String?> uploadProfilePhoto({
    required String userId,
    required File photoFile,
  }) async {
    try {
      final extension = path.extension(photoFile.path);
      final ref = _storage.ref().child('profiles/$userId/avatar$extension');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      await ref.putFile(photoFile, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading profile photo: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // UTILITY METHODS
  // ---------------------------------------------------------------------------

  /// Delete a file by its download URL
  Future<bool> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  /// Get all symptom images for a patient
  Future<List<String>> getPatientSymptomImages(String patientId) async {
    try {
      final listResult =
          await _storage.ref().child('symptoms/$patientId').listAll();
      final urls = <String>[];

      for (final item in listResult.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      debugPrint('Error getting patient symptom images: $e');
      return [];
    }
  }

  /// Get all lab results for a request
  Future<List<String>> getLabResults(String requestId) async {
    try {
      final listResult =
          await _storage.ref().child('lab_results/$requestId').listAll();
      final urls = <String>[];

      for (final item in listResult.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      debugPrint('Error getting lab results: $e');
      return [];
    }
  }

  /// Upload from bytes (useful for web platform)
  Future<String?> uploadFromBytes({
    required String storagePath,
    required Uint8List bytes,
    required String fileName,
    String contentType = 'application/octet-stream',
  }) async {
    try {
      final ref = _storage.ref().child('$storagePath/$fileName');

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      await ref.putData(bytes, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading from bytes: $e');
      return null;
    }
  }
}
