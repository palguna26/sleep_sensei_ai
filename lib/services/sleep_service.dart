import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/sleep_session.dart';

class SleepService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> logSession(String uid, DateTime start, DateTime end) async {
    final session = SleepSession(id: const Uuid().v4(), start: start, end: end, source: '');
    await _firestore.collection('users/$uid/sessions').doc(session.id).set(session.toMap());
  }

  Future<List<SleepSession>> getSessions(String uid) async {
    final snap = await _firestore
        .collection('users/$uid/sessions')
        .orderBy('start', descending: true)
        .limit(14)
        .get();

    return snap.docs.map((doc) => SleepSession.fromMap(doc.data())).toList();
  }
}
