import 'package:flutter/material.dart';

import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
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
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? const Color(0xff6c4df6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: const Color(0xff6c4df6),
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 21,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: task.isCompleted
                    ? Colors.black45
                    : const Color(0xff29255e),
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            tooltip: 'Edit task',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xfffff2d9),
            ),
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xffffa726),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Delete task',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xffffe8ec),
            ),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xffef5364),
            ),
          ),
        ],
      ),
    );
  }
}