import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/firebase_service.dart';

class TodoViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  bool isLoading = false;
  String? errorMessage;

  Stream<List<TaskModel>> get tasks {
    return _firebaseService.getTasks();
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    await _run(() => _firebaseService.addTask(title));
  }

  Future<void> toggleTask(TaskModel task) async {
    await _run(() => _firebaseService.toggleTask(task));
  }

  Future<void> deleteTask(String taskId) async {
    await _run(() => _firebaseService.deleteTask(taskId));
  }

  Future<void> deleteAllTasks() async {
    await _run(_firebaseService.deleteAllTasks);
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await action();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}