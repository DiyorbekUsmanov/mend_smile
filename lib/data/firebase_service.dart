import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> _ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  Future<void> createPatient({
    required String name,
    required String phone,
    required DateTime surgeryDate,
  }) async {
    await _ensureSignedIn();
    final uid = _auth.currentUser!.uid;
    await _db.collection('patients').doc(uid).set({
      'name': name,
      'phone': phone,
      'surgeryDate': surgeryDate.toIso8601String(),
      'surgeryDateMillis': surgeryDate.millisecondsSinceEpoch,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> patientStatusStream() {
    final uid = _auth.currentUser!.uid;
    return _db.collection('patients').doc(uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> pendingPatientsStream() {
    return _db
        .collection('patients')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> approvePatient(String docId) {
    return _db.collection('patients').doc(docId).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }
}
