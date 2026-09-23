import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';

class FirebaseService {
  final CollectionReference<Map<String, dynamic>> _tasks =
      FirebaseFirestore.instance.collection('tasks');

  Stream<List<TaskModel>> getTasks() {
    return _tasks
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((document) => TaskModel.fromFirestore(document))
              .toList(),
        );
  }

  Future<void> addTask(String title) async {
    await _tasks.add({
      'title': title.trim(),
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> editTask(
    String taskId,
    String newTitle,
  ) async {
    await _tasks.doc(taskId).update({
      'title': newTitle.trim(),
    });
  }

  Future<void> toggleTask(TaskModel task) async {
    await _tasks.doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _tasks.doc(taskId).delete();
  }

  Future<void> deleteAllTasks() async {
    final snapshot = await _tasks.get();

    if (snapshot.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();

    for (final document in snapshot.docs) {
      batch.delete(document.reference);
    }

    await batch.commit();
  }
}