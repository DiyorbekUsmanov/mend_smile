import 'package:cloud_firestore/cloud_firestore.dart';

class DocFirebaseService {
  DocFirebaseService._();
  static final DocFirebaseService instance = DocFirebaseService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> pendingPatientsStream() {
    return _db
        .collection('patients')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> approvedPatientsStream() {
    return _db
        .collection('patients')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> approvePatient(String docId) {
    return _db.collection('patients').doc(docId).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getPatientProfile(String docId) async {
    final doc = await _db.collection('patients').doc(docId).get();
    return doc.exists ? doc.data() : null;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> patientStatusStream(String docId) {
    return _db.collection('patients').doc(docId).snapshots();
  }
}
