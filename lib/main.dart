import 'package:flutter/material.dart';
import 'ActionButtons.dart';
import 'ApiControler.dart';
import 'EditTaskWindow.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  ApiController newApiControler = ApiController();

  @override
  Widget build(BuildContext context) {
    newApiControler.testApiConnection();
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final ApiController apiController = ApiController();
  final List<Map<String, dynamic>> taskList = [];
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();
  int? selectedTaskId; // Store the ID of the selected task

  @override
  void initState() {
    super.initState();
    _fetchTasks(); // Fetch tasks when the screen is initialized
  }

  void _fetchTasks() async {
  try {
    final tasks = await apiController.fetchTasks();
    setState(() {
      taskList.clear();
      // Ensure isFavorite is never null, set a default value of false (or 0)
      taskList.addAll(tasks.map((task) {
        return {
          ...task,
          'isFavorite': task['isFavorite'] ?? false, // Default to false if null
        };
      }).toList());
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch tasks: $e')),
    );
  }
        _fetchTasks();
}

  void _addTask() async {
    final taskName = _taskNameController.text;
    final taskDescription = _taskDescriptionController.text;

    if (taskName.isNotEmpty && taskDescription.isNotEmpty) {
      try {
        final newTask = await apiController.addTask(taskName, taskDescription);
        setState(() {
          taskList.add(newTask);
        });
        _taskNameController.clear();
        _taskDescriptionController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add task: $e')),
        );
      }
    }
  }

  // Delete Task Method
  void _deleteTask() async {
    if (selectedTaskId != null) {
      try {
        await apiController.deleteTask(selectedTaskId!); // Call delete method
        setState(() {
          taskList.removeWhere((task) => task['id'] == selectedTaskId);
          selectedTaskId = null; // Reset selected tasks
        });
        print('Updated task list: $taskList');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully')),
        );
      } catch (e) {
        // Handle error
      }
      _fetchTasks();
    }
  }

  void _editTask() {
    if (selectedTaskId != null) {
      final selectedTask = taskList.firstWhere((task) => task['id'] == selectedTaskId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditTaskScreen(
            task: selectedTask,
            onSave: (updatedTask) async {
              try {
                await apiController.updateTask(
                  selectedTaskId!,
                  updatedTask['name'],
                  updatedTask['description'],
                  updatedTask['isfavorite'] ?? false,
                );
                setState(() {
                  final index = taskList.indexWhere((task) => task['id'] == selectedTaskId);
                  taskList[index] = updatedTask;
                  selectedTaskId = null;
                });
                _fetchTasks();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update task: $e')),
                );
              }
            },
          ),
        ),
      );
    }
  }

void _toggleFavorite(Map<String, dynamic> task) async {
  // Toggle the favorite status locally, considering 0/1 values from the database
  setState(() {
    task['isFavorite'] = (task['isFavorite'] == 1) ? 0 : 1; // Toggle between 0 and 1
  });

  try {
    // Call the updateTask function in your ApiController
    await apiController.updateTask(
      task['id'],  // Pass the task ID
      task['name'],  // Pass the task name
      task['description'],  // Pass the task description
      task['isFavorite'] == 1,  // Pass the updated value as boolean (true/false)
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task favorite status updated')),
    );
  } catch (e) {
    // Revert the change locally if the update fails
    setState(() {
      task['isFavorite'] = (task['isFavorite'] == 1) ? 0 : 1; // Revert toggle
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update task favorite status: $e')),
    );
  }
  _fetchTasks(); // Refresh the task list
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('To-Do List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: taskList.length + 1, // Add 1 for the input field
                itemBuilder: (context, index) {
                  if (index < taskList.length) {
                    final task = taskList[index];
                    return ListTile(
                      title: Text(task['name']),
                      subtitle: Text(task['description'] ?? ''),
                      tileColor: task['id'] == selectedTaskId
                          ? Colors.blue.shade100 // Highlight selected task
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Heart icon with toggle functionality
                          IconButton(
                            icon: Icon(
                              task['isFavorite'] == true || task['isFavorite'] == 1
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: task['isFavorite'] == true || task['isFavorite'] == 1
                                  ? Colors.red
                                  : null,
                            ),
                            onPressed: () {
                              _toggleFavorite(task); // Toggle the favorite status
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          if (selectedTaskId == task['id']) {
                            selectedTaskId = null; // Deselect if tapped again
                          } else {
                            selectedTaskId = task['id']; // Select the task
                          }
                        });
                      },
                    );
                  } else {
                    return _TaskInputField(
                      taskNameController: _taskNameController,
                      taskDescriptionController: _taskDescriptionController,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ActionButtons(
        key: const Key('action_buttons'),  // Unique key for the ActionButtons widget
        onAdd: _addTask,
        onEdit: _editTask,
        onDelete: _deleteTask,
      ),
    );
  }
}

class _TaskInputField extends StatelessWidget {
  final TextEditingController taskNameController;
  final TextEditingController taskDescriptionController;

  const _TaskInputField({
    required this.taskNameController,
    required this.taskDescriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: taskNameController,
            decoration: const InputDecoration(
              labelText: 'Task Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: taskDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Task Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
