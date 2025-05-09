// Örnek: Takvim Görünümü
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task_manager/main.dart';

class CalendarViewScreen extends StatefulWidget {
  final List<Task> tasks;

  const CalendarViewScreen({Key? key, required this.tasks}) : super(key: key);

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<Task>> _tasksByDay;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _initTasksByDay();
  }

  void _initTasksByDay() {
    _tasksByDay = {};
    for (var task in widget.tasks) {
      final date = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );

      if (_tasksByDay[date] == null) {
        _tasksByDay[date] = [];
      }

      _tasksByDay[date]!.add(task);
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _tasksByDay[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim Görünümü'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getTasksForDay,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    final tasksForSelectedDay = _getTasksForDay(_selectedDay);

    if (tasksForSelectedDay.isEmpty) {
      return const Center(
        child: Text('Bu gün için görev yok'),
      );
    }

    return ListView.builder(
      itemCount: tasksForSelectedDay.length,
      itemBuilder: (context, index) {
        final task = tasksForSelectedDay[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description),
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (value) {
              // Görev tamamlama durumunu güncelle
            },
          ),
        );
      },
    );
  }
}
