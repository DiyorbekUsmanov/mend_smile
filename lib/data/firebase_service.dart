// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mend_smile/core/log_services.dart';
//
// import '../core/session_manager.dart';
//
// class FirebaseService {
//   FirebaseService._();
//   static final FirebaseService instance = FirebaseService._();
//
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   // Store current patient document ID for tracking
//   String? _currentPatientDocId;
//
//   Future<String> createPatient({
//     required String name,
//     required String phone,
//     required DateTime surgeryDate,
//   }) async {
//     // Use phone as document ID to ensure uniqueness and easy lookup
//     final docId = phone.replaceAll(RegExp(r'[^\d]'), ''); // Remove non-digits
//
//     await _db.collection('patients').doc(docId).set({
//       'name': name,
//       'phone': phone,
//       'surgeryDate': surgeryDate.toIso8601String(),
//       'surgeryDateMillis': surgeryDate.millisecondsSinceEpoch,
//       'status': 'pending',
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//
//     _currentPatientDocId = docId;
//     LogService.d("Patient created with ID: $docId");
//     return docId;
//   }
//
//   Stream<DocumentSnapshot<Map<String, dynamic>>> patientStatusStream(String docId) {
//     return _db.collection('patients').doc(docId).snapshots();
//   }
//
//   Stream<QuerySnapshot<Map<String, dynamic>>> pendingPatientsStream() {
//     return _db
//         .collection('patients')
//         .where('status', isEqualTo: 'pending')
//         .orderBy('createdAt', descending: true)
//         .snapshots();
//   }
//   Stream<QuerySnapshot<Map<String, dynamic>>> approvedPatientsStream() {
//     return _db
//         .collection('patients')
//         .where('status', isEqualTo: 'approved')
//         .orderBy('createdAt', descending: true)
//         .snapshots();
//   }
//
//   Future<void> approvePatient(String docId) {
//     return _db.collection('patients').doc(docId).update({
//       'status': 'approved',
//       'approvedAt': FieldValue.serverTimestamp(),
//     });
//   }
//
//   Future<Map<String, dynamic>?> getPatientProfile(String docId) async {
//     final doc = await _db.collection('patients').doc(docId).get();
//     if (doc.exists) {
//       return doc.data();
//     }
//     return null;
//   }
//
//   Future<Map<String, dynamic>?> checkPatientExists(String name, String phone) async {
//     final query = await _db
//         .collection('patients')
//         .where('name', isEqualTo: name.trim())
//         .where('phone', isEqualTo: phone.trim())
//         .limit(1)
//         .get();
//
//     if (query.docs.isNotEmpty) {
//       return {
//         'data': query.docs.first.data(),
//         'docId': query.docs.first.id,
//       };
//     }
//     return null;
//   }
//
//   Future<String> signInByPatientName(String name) async {
//     final query = await _db
//         .collection('patients')
//         .where('name', isEqualTo: name)
//         .limit(1)
//         .get();
//
//     if (query.docs.isEmpty) {
//       throw Exception('No patient found with that name.');
//     }
//
//     final patientData = query.docs.first.data();
//     if (patientData['status'] != 'approved') {
//       throw Exception('Patient found, but not yet approved by dentist.');
//     }
//
//     final docId = query.docs.first.id;
//     _currentPatientDocId = docId;
//
//     // Save session locally
//     await SessionManager.saveSession('patient');
//
//     return docId;
//   }
//
//   // Helper method to get current patient doc ID
//   String? getCurrentPatientDocId() {
//     return _currentPatientDocId;
//   }
//
//   // Helper method to set current patient doc ID
//   void setCurrentPatientDocId(String docId) {
//     _currentPatientDocId = docId;
//   }
//
//   Future<void> submitQA({
//     required int painLevel,
//     required bool hasHeadache,
//     required int mealsPerDay,
//     required String note,
//   }) async {
//     final docId = _currentPatientDocId;
//     if (docId == null) throw Exception("No patient signed in.");
//
//     final today = DateTime.now();
//     final dateId = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
//
//     await _db
//         .collection('patients')
//         .doc(docId)
//         .collection('qa')
//         .doc(dateId)
//         .set({
//       'painLevel': painLevel,
//       'hasHeadache': hasHeadache,
//       'mealsPerDay': mealsPerDay,
//       'note': note,
//       'submittedAt': FieldValue.serverTimestamp(),
//     });
//   }
//
//   Future<bool> hasSubmittedQAForToday() async {
//     final docId = _currentPatientDocId;
//     if (docId == null) return false;
//
//     final today = DateTime.now();
//     final dateId = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
//
//     final snapshot = await _db
//         .collection('patients')
//         .doc(docId)
//         .collection('qa')
//         .doc(dateId)
//         .get();
//     return snapshot.exists;
//   }
//
//   Stream<QuerySnapshot<Map<String, dynamic>>> get quizDatesStream {
//
//     return FirebaseFirestore.instance
//         .collection('patients')
//         .doc(patientId)
//         .collection('qa')
//         .orderBy('submittedAt', descending: true)
//         .snapshots();
//   }
//
//
// }