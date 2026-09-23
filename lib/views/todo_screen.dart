import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../viewmodels/todo_viewmodel.dart';
import '../widgets/task_card.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final taskController = TextEditingController();

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  Future<void> addTask() async {
    final title = taskController.text.trim();

    if (title.isEmpty) {
      showMessage('Please enter a task');
      return;
    }

    await context.read<TodoViewModel>().addTask(title);

    if (!mounted) return;

    final error = context.read<TodoViewModel>().errorMessage;

    if (error == null) {
      taskController.clear();
      FocusScope.of(context).unfocus();
    } else {
      showMessage(error);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> showEditDialog(TaskModel task) async {
    final editController = TextEditingController(
      text: task.title,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xffeef2ff),
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Enter task title',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              updateTask(
                dialogContext,
                task.id,
                editController.text,
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                updateTask(
                  dialogContext,
                  task.id,
                  editController.text,
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    editController.dispose();
  }

  void updateTask(
    BuildContext dialogContext,
    String taskId,
    String title,
  ) {
    if (title.trim().isEmpty) return;

    Navigator.pop(dialogContext);

    context.read<TodoViewModel>().editTask(
          taskId,
          title,
        );
  }

  Future<void> confirmDelete(TaskModel task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text(
            'Delete "${task.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xffef5364),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      await context.read<TodoViewModel>().deleteTask(task.id);
    }
  }

  Future<void> confirmDeleteAll() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete All Tasks'),
          content: const Text(
            'Are you sure you want to delete all tasks?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xffef5364),
              ),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      await context.read<TodoViewModel>().deleteAllTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TodoViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xffeef2ff),
      appBar: AppBar(
        title: const Text(
          'TodoCraft 3D',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff29255e),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: confirmDeleteAll,
            tooltip: 'Delete all tasks',
            icon: const Icon(
              Icons.delete_sweep_outlined,
              color: Color(0xffef5364),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (viewModel.isLoading)
            const LinearProgressIndicator(
              color: Color(0xff6c4df6),
              backgroundColor: Colors.transparent,
            ),
          Expanded(
            child: StreamBuilder<List<TaskModel>>(
              stream: viewModel.tasks,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _message(
                    Icons.cloud_off_rounded,
                    'Unable to load tasks',
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff6c4df6),
                    ),
                  );
                }

                final tasks = snapshot.data!;
                final completedTasks = tasks
                    .where((task) => task.isCompleted)
                    .length;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 40,
                        vertical: 20,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 750,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Plan your day',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff29255e),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Stay focused and complete your tasks',
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 25),
                              Row(
                                children: [
                                  Expanded(
                                    child: _summaryCard(
                                      icon: Icons.list_alt_rounded,
                                      value: tasks.length,
                                      label: 'Tasks',
                                      color:
                                          const Color(0xff6c4df6),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: _summaryCard(
                                      icon:
                                          Icons.task_alt_rounded,
                                      value: completedTasks,
                                      label: 'Completed',
                                      color:
                                          const Color(0xff24c7a3),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              _taskInput(),
                              const SizedBox(height: 30),
                              const Text(
                                'My Tasks',
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff29255e),
                                ),
                              ),
                              const SizedBox(height: 18),
                              if (tasks.isEmpty)
                                _emptyTasks()
                              else
                                ...tasks.map(
                                  (task) => TaskCard(
                                    task: task,
                                    onToggle: () {
                                      viewModel.toggleTask(task);
                                    },
                                    onEdit: () {
                                      showEditDialog(task);
                                    },
                                    onDelete: () {
                                      confirmDelete(task);
                                    },
                                  ),
                                ),
                              const SizedBox(height: 20),
                              const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.cloud_done_rounded,
                                      size: 20,
                                      color: Color(0xff6c4df6),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Synced with Firebase',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 7, 5),
      decoration: BoxDecoration(
        color: const Color(0xffeef2ff),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Color(0x355c6692),
            offset: Offset(6, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: taskController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => addTask(),
              decoration: const InputDecoration(
                hintText: 'Add a new task',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton.filled(
            onPressed: addTask,
            tooltip: 'Add task',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xff6c4df6),
              padding: const EdgeInsets.all(15),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required int value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffeef2ff),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Color(0x355c6692),
            offset: Offset(6, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 34, color: color),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff29255e),
                  ),
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyTasks() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 75,
              color: Color(0xffb5addf),
            ),
            SizedBox(height: 15),
            Text(
              'No tasks yet',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xff29255e),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Add your first task above',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 65,
            color: const Color(0xffef5364),
          ),
          const SizedBox(height: 15),
          Text(
            message,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}