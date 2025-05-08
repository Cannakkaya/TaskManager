import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF121212),
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class Task {
  String id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  String priority;
  List<String> tags;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.priority,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority,
      'tags': tags,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'],
      priority: json['priority'],
      tags: List<String>.from(json['tags']),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterPriority = 'All';
  bool _showCompleted = true;
  late TabController _tabController;
  final List<String> _availableTags = [
    'Work',
    'Personal',
    'Shopping',
    'Health',
    'Finance',
    'Education'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('tasks');

      if (tasksJson != null) {
        final List<dynamic> decodedTasks = jsonDecode(tasksJson);
        setState(() {
          _tasks = decodedTasks.map((task) => Task.fromJson(task)).toList();
          _applyFilters();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson =
          jsonEncode(_tasks.map((task) => task.toJson()).toList());
      await prefs.setString('tasks', tasksJson);
    } catch (e) {
      // Handle error
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTasks = _tasks.where((task) {
        // Filter by search query
        final matchesSearch =
            task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                task.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                task.tags.any((tag) =>
                    tag.toLowerCase().contains(_searchQuery.toLowerCase()));

        // Filter by priority
        final matchesPriority =
            _filterPriority == 'All' || task.priority == _filterPriority;

        // Filter by completion status
        final matchesCompletion = _showCompleted || !task.isCompleted;

        return matchesSearch && matchesPriority && matchesCompletion;
      }).toList();

      // Sort by due date
      _filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    });
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
      _applyFilters();
    });
    _saveTasks();
  }

  void _updateTask(Task updatedTask) {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        _applyFilters();
      }
    });
    _saveTasks();
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((task) => task.id == id);
      _applyFilters();
    });
    _saveTasks();
  }

  void _toggleTaskCompletion(String id) {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index].isCompleted = !_tasks[index].isCompleted;
        _applyFilters();
      }
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Tasks'),
            Tab(text: 'Statistics'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTasksTab(),
                _buildStatisticsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTasksTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _applyFilters();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
          ),
        ),
        Expanded(
          child: _filteredTasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No tasks yet'
                            : 'No matching tasks found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredTasks.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final task = _filteredTasks[index];
                    final isOverdue = task.dueDate.isBefore(DateTime.now()) &&
                        !task.isCompleted;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Slidable(
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                _showEditTaskDialog(task);
                              },
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (_) {
                                _deleteTask(task.id);
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              _showTaskDetailsDialog(task);
                            },
                            borderRadius: BorderRadius.circular(12),
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
                                            color: task.isCompleted
                                                ? Colors.grey
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Checkbox(
                                        value: task.isCompleted,
                                        onChanged: (value) {
                                          _toggleTaskCompletion(task.id);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    task.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: isOverdue
                                            ? Colors.red
                                            : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('MMM dd, yyyy')
                                            .format(task.dueDate),
                                        style: TextStyle(
                                          color: isOverdue
                                              ? Colors.red
                                              : Colors.grey[600],
                                          fontWeight: isOverdue
                                              ? FontWeight.bold
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      _buildPriorityChip(task.priority),
                                    ],
                                  ),
                                  if (task.tags.isNotEmpty) ...[
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
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    final totalTasks = _tasks.length;
    final completedTasks = _tasks.where((task) => task.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;
    final overdueTasks = _tasks
        .where((task) =>
            task.dueDate.isBefore(DateTime.now()) && !task.isCompleted)
        .length;

    final highPriorityTasks =
        _tasks.where((task) => task.priority == 'High').length;
    final mediumPriorityTasks =
        _tasks.where((task) => task.priority == 'Medium').length;
    final lowPriorityTasks =
        _tasks.where((task) => task.priority == 'Low').length;

    // Calculate tag statistics
    final Map<String, int> tagStats = {};
    for (var task in _tasks) {
      for (var tag in task.tags) {
        tagStats[tag] = (tagStats[tag] ?? 0) + 1;
      }
    }

    // Sort tags by frequency
    final sortedTags = tagStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Task Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatItem('Total Tasks', totalTasks, Icons.assignment),
                  const Divider(),
                  _buildStatItem(
                      'Completed', completedTasks, Icons.check_circle,
                      color: Colors.green),
                  const Divider(),
                  _buildStatItem('Pending', pendingTasks, Icons.pending_actions,
                      color: Colors.orange),
                  const Divider(),
                  _buildStatItem('Overdue', overdueTasks, Icons.warning,
                      color: Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Priority Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatItem(
                      'High Priority', highPriorityTasks, Icons.priority_high,
                      color: Colors.red),
                  const Divider(),
                  _buildStatItem('Medium Priority', mediumPriorityTasks,
                      Icons.remove_circle,
                      color: Colors.orange),
                  const Divider(),
                  _buildStatItem(
                      'Low Priority', lowPriorityTasks, Icons.arrow_downward,
                      color: Colors.green),
                ],
              ),
            ),
          ),
          if (sortedTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...sortedTags.map((entry) {
                      return Column(
                        children: [
                          _buildStatItem(entry.key, entry.value, Icons.label),
                          if (entry != sortedTags.last) const Divider(),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Completion Rate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: totalTasks > 0 ? completedTasks / totalTasks : 0,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${totalTasks > 0 ? ((completedTasks / totalTasks) * 100).toStringAsFixed(1) : 0}% Complete',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    switch (priority) {
      case 'High':
        color = Colors.red;
        break;
      case 'Medium':
        color = Colors.orange;
        break;
      case 'Low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempFilterPriority = _filterPriority;
        bool tempShowCompleted = _showCompleted;

        return AlertDialog(
          title: const Text('Filter Tasks'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Priority',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: tempFilterPriority == 'All',
                        onSelected: (selected) {
                          setState(() {
                            tempFilterPriority = 'All';
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('High'),
                        selected: tempFilterPriority == 'High',
                        onSelected: (selected) {
                          setState(() {
                            tempFilterPriority = 'High';
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Medium'),
                        selected: tempFilterPriority == 'Medium',
                        onSelected: (selected) {
                          setState(() {
                            tempFilterPriority = 'Medium';
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Low'),
                        selected: tempFilterPriority == 'Low',
                        onSelected: (selected) {
                          setState(() {
                            tempFilterPriority = 'Low';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: tempShowCompleted,
                        onChanged: (value) {
                          setState(() {
                            tempShowCompleted = value!;
                          });
                        },
                      ),
                      const Text('Show completed tasks'),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filterPriority = tempFilterPriority;
                  _showCompleted = tempShowCompleted;
                  _applyFilters();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String selectedPriority = 'Medium';
    List<String> selectedTags = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter task title',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter task description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Due Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(selectedDate),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Priority',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Low'),
                          selected: selectedPriority == 'Low',
                          onSelected: (selected) {
                            setState(() {
                              selectedPriority = 'Low';
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Medium'),
                          selected: selectedPriority == 'Medium',
                          onSelected: (selected) {
                            setState(() {
                              selectedPriority = 'Medium';
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('High'),
                          selected: selectedPriority == 'High',
                          onSelected: (selected) {
                            setState(() {
                              selectedPriority = 'High';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _availableTags.map((tag) {
                        return FilterChip(
                          label: Text(tag),
                          selected: selectedTags.contains(tag),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedTags.add(tag);
                              } else {
                                selectedTags.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a title'),
                        ),
                      );
                      return;
                    }

                    final newTask = Task(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      dueDate: selectedDate,
                      priority: selectedPriority,
                      tags: selectedTags,
                    );

                    _addTask(newTask);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTaskDialog(Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    DateTime selectedDate = task.dueDate;
    String selectedPriority = task.priority;
    List<String> selectedTags = List.from(task.tags);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter task title',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter task description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Due Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(selectedDate),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Priority',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Low'),
                          selected: selectedPriority == 'Low',
                          onSelected: (selected) {
                            setState(() {
                              selectedPriority = 'Low';
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Medium'),
                          selected: selectedPriority == 'Medium',
                          onSelected: (selected) {
                            setState(() {
                              selectedPriority = 'Medium';
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('High'),
                          selected: selectedPriority == 'High',
                          onSelected: (selected) {
                            setState(() {
                              selectedPriority = 'High';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _availableTags.map((tag) {
                        return FilterChip(
                          label: Text(tag),
                          selected: selectedTags.contains(tag),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedTags.add(tag);
                              } else {
                                selectedTags.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a title'),
                        ),
                      );
                      return;
                    }

                    final updatedTask = Task(
                      id: task.id,
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      dueDate: selectedDate,
                      isCompleted: task.isCompleted,
                      priority: selectedPriority,
                      tags: selectedTags,
                    );

                    _updateTask(updatedTask);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Update Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTaskDetailsDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.description,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.flag,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Priority: ${task.priority}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${task.isCompleted ? 'Completed' : 'Pending'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Tags:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: task.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _toggleTaskCompletion(task.id);
                Navigator.of(context).pop();
              },
              child: Text(
                task.isCompleted ? 'Mark as Pending' : 'Mark as Completed',
              ),
            ),
          ],
        );
      },
    );
  }
}
