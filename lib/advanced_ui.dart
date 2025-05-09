// Örnek: Özelleştirilebilir Widget'lar
import 'package:flutter/material.dart';
import 'package:task_manager/main.dart';
import 'package:intl/intl.dart';

class CustomizableTaskTile extends StatelessWidget {
  final Task task;
  final Function(Task) onTaskUpdated;
  final Function(String) onTaskDeleted;
  final Map<String, dynamic> customization;

  const CustomizableTaskTile({
    Key? key,
    required this.task,
    required this.onTaskUpdated,
    required this.onTaskDeleted,
    required this.customization,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showDescription = customization['showDescription'] ?? true;
    final showTags = customization['showTags'] ?? true;
    final showDueDate = customization['showDueDate'] ?? true;
    final showPriority = customization['showPriority'] ?? true;
    final tileHeight = customization['tileHeight'] ?? 'medium';
    final cornerRadius = customization['cornerRadius'] ?? 12.0;

    double height;
    switch (tileHeight) {
      case 'small':
        height = 60.0;
        break;
      case 'medium':
        height = 100.0;
        break;
      case 'large':
        height = 140.0;
        break;
      default:
        height = 100.0;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      child: Container(
        height: showDescription ? null : height,
        child: InkWell(
          onTap: () {
            // Görev detaylarını göster
          },
          borderRadius: BorderRadius.circular(cornerRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        final updatedTask = Task(
                          id: task.id,
                          title: task.title,
                          description: task.description,
                          dueDate: task.dueDate,
                          isCompleted: value ?? false,
                          priority: task.priority,
                          tags: task.tags,
                        );
                        onTaskUpdated(updatedTask);
                      },
                    ),
                  ],
                ),
                if (showDescription && task.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (showDueDate) ...[
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(task.dueDate),
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (showPriority) ...[
                      _buildPriorityChip(task.priority),
                    ],
                  ],
                ),
                if (showTags && task.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: task.tags.map((tag) {
                      return Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    // Öncelik chip'i oluşturma kodu...
    return Container();
  }
}
