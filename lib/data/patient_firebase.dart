import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mend_smile/core/log_services.dart';
import 'package:mend_smile/core/session_manager.dart';

class PatientFirebaseService {
  PatientFirebaseService._();

  static final PatientFirebaseService instance = PatientFirebaseService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? _currentPatientDocId;

  Future<String> createPatient({
    required String name,
    required String phone,
    required DateTime surgeryDate,
  }) async {
    final docId = phone.replaceAll(RegExp(r'[^\d]'), '');

    await _db.collection('patients').doc(docId).set({
      'name': name,
      'phone': phone,
      'surgeryDate': surgeryDate.toIso8601String(),
      'surgeryDateMillis': surgeryDate.millisecondsSinceEpoch,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _currentPatientDocId = docId;
    LogService.d("Patient created with ID: $docId");
    return docId;
  }

  Future<String> signInByPatientName(String name) async {
    final query = await _db
        .collection('patients')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (query.docs.isEmpty) throw Exception('No patient found with that name.');
    final patient = query.docs.first;

    if (patient.data()['status'] != 'approved') {
      throw Exception('Patient not yet approved by dentist.');
    }

    _currentPatientDocId = patient.id;
    await SessionManager.saveSession('patient');

    return patient.id;
  }

  Future<Map<String, dynamic>?> checkPatientExists(
    String name,
    String phone,
  ) async {
    final query = await _db
        .collection('patients')
        .where('name', isEqualTo: name.trim())
        .where('phone', isEqualTo: phone.trim())
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return {'data': query.docs.first.data(), 'docId': query.docs.first.id};
    }
    return null;
  }

  Future<void> submitQA({
    required int painLevel,
    required bool hasHeadache,
    required int mealsPerDay,
    required String note,
  }) async {
    final docId = _currentPatientDocId;
    if (docId == null) throw Exception("No patient signed in.");

    final today = DateTime.now();
    final dateId =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    await _db
        .collection('patients')
        .doc(docId)
        .collection('qa')
        .doc(dateId)
        .set({
          'painLevel': painLevel,
          'hasHeadache': hasHeadache,
          'mealsPerDay': mealsPerDay,
          'note': note,
          'submittedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<bool> hasSubmittedQAForToday() async {
    final docId = _currentPatientDocId;
    if (docId == null) return false;

    final today = DateTime.now();
    final dateId =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final snapshot = await _db
        .collection('patients')
        .doc(docId)
        .collection('qa')
        .doc(dateId)
        .get();

    return snapshot.exists;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> quizDatesStreamForPatient(
    String patientId,
  ) {
    return _db
        .collection('patients')
        .doc(patientId)
        .collection('qa')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getPatientProfile(String docId) async {
    final doc = await _db.collection('patients').doc(docId).get();
    return doc.exists ? doc.data() : null;
  }

  String? getCurrentPatientDocId() => _currentPatientDocId;

  void setCurrentPatientDocId(String docId) => _currentPatientDocId = docId;
}
