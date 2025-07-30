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

  Future<void> saveVideoStatusForToday(Map<String, bool> statusMap) async {
    final docId = _currentPatientDocId;
    if (docId == null) return;

    final todayKey = _todayKey();
    await _db.collection('patients').doc(docId).collection('videoStatus').doc(todayKey).set({
      'completedVideos': statusMap,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, bool>> loadVideoStatusForToday() async {
    final docId = _currentPatientDocId;
    if (docId == null) return {};

    final todayKey = _todayKey();
    final doc = await _db.collection('patients').doc(docId).collection('videoStatus').doc(todayKey).get();

    if (!doc.exists) return {};
    final data = doc.data();
    final map = data?['completedVideos'] as Map<String, dynamic>? ?? {};
    return map.map((key, value) => MapEntry(key, value as bool));
  }

  String _todayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> submitQA({
    required double painLevel,
    required String painTime,
    required double swellingReduction,
    required List<String> eatingIssues,
    required String weightChange,
    required String weightLossAmount,
    required bool hygieneIssue,
    required String hygieneDetails,
    required List<String> speakingIssues,
    required String faceMovementLimit,
    required double lipSymptoms,
    required String sleepChange,
    required double overallHealth,
    required String medicalVisits,
    required String doctorInstructionsFollow,
    required String psychologicalState,
    required String returnToWork,
  }) async {
    final docId = _currentPatientDocId;
    if (docId == null) throw Exception("No patient signed in.");

    final today = DateTime.now();
    final dateId = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    await _db.collection('patients').doc(docId).collection('qa').doc(dateId).set({
      'painLevel': painLevel,
      'painTime': painTime,
      'swellingReduction': swellingReduction,
      'eatingIssues': eatingIssues,
      'weightChange': weightChange,
      'weightLossAmount': weightLossAmount,
      'hygieneIssue': hygieneIssue,
      'hygieneDetails': hygieneDetails,
      'speakingIssues': speakingIssues,
      'faceMovementLimit': faceMovementLimit,
      'lipSymptoms': lipSymptoms,
      'sleepChange': sleepChange,
      'overallHealth': overallHealth,
      'medicalVisits': medicalVisits,
      'doctorInstructionsFollow': doctorInstructionsFollow,
      'psychologicalState': psychologicalState,
      'returnToWork': returnToWork,
      'submittedAt': FieldValue.serverTimestamp(),
    });
    await FirebaseFirestore.instance
        .collection('patients')
        .doc(_currentPatientDocId)
        .update({'forceQaAccess': false});

  }

  Future<bool> canSubmitQA() async {
    final docId = _currentPatientDocId;
    if (docId == null) return false;

    final patientDoc = await FirebaseFirestore.instance.collection('patients').doc(docId).get();
    final forceAccess = patientDoc.data()?['forceQaAccess'] == true;

    if (forceAccess) return true;

    final qaCollection = patientDoc.reference.collection('qa');
    final snapshot = await qaCollection.orderBy('submittedAt', descending: true).limit(1).get();

    if (snapshot.docs.isEmpty) return true;

    final lastSubmitted = (snapshot.docs.first['submittedAt'] as Timestamp).toDate();
    return DateTime.now().difference(lastSubmitted).inDays >= 7;
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
