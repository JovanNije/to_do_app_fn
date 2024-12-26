import 'package:flutter/material.dart';

class EditTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic>) onSave;

  const EditTaskScreen({
    required this.task,
    required this.onSave,
    super.key,
  });

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task['name']);
    _descriptionController = TextEditingController(text: widget.task['description']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Task Description',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  // Unique tag for the Cancel button
                  key: Key('cancel_button_${widget.task['id']}'),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updatedTask = {
                      ...widget.task,
                      'name': _nameController.text,
                      'description': _descriptionController.text,
                    };
                    widget.onSave(updatedTask);
                    Navigator.pop(context);
                  },
                  // Unique tag for the Save button
                  key: Key('save_button_${widget.task['id']}'),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
