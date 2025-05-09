// Örnek: Firebase ile Senkronizasyon
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/main.dart';

class CloudSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> syncTasks(List<Task> tasks) async {
    if (_auth.currentUser == null) return;

    final userId = _auth.currentUser!.uid;
    final batch = _firestore.batch();

    // Önce tüm görevleri sil
    final tasksRef =
        _firestore.collection('users').doc(userId).collection('tasks');
    final existingTasks = await tasksRef.get();
    for (var doc in existingTasks.docs) {
      batch.delete(doc.reference);
    }

    // Sonra tüm görevleri ekle
    for (var task in tasks) {
      final docRef = tasksRef.doc(task.id);
      batch.set(docRef, task.toJson());
    }

    await batch.commit();
  }

  Future<List<Task>> fetchTasks() async {
    if (_auth.currentUser == null) return [];

    final userId = _auth.currentUser!.uid;
    final tasksRef =
        _firestore.collection('users').doc(userId).collection('tasks');
    final snapshot = await tasksRef.get();

    return snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
  }
}
