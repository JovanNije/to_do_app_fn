import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  // Constructor to pass actions for add, edit, and delete buttons
  const ActionButtons({
    super.key,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Add button
        FloatingActionButton(
          onPressed: onAdd,
          tooltip: 'Add',
          backgroundColor: Colors.green,
          // Unique tag for the Add button
          key: const Key('add_button'),
          child: const Icon(Icons.add),
        ),
        const SizedBox(width: 16), // Space between the buttons
        // Edit button
        FloatingActionButton(
          onPressed: onEdit,
          tooltip: 'Edit',
          backgroundColor: Colors.blue,
          // Unique tag for the Edit button
          key: const Key('edit_button'),
          child: const Icon(Icons.edit),
        ),
        const SizedBox(width: 16), // Space between the buttons
        // Delete button
        FloatingActionButton(
          onPressed: onDelete,
          tooltip: 'Delete',
          backgroundColor: Colors.red,
          // Unique tag for the Delete button
          key: const Key('delete_button'),
          child: const Icon(Icons.delete),
        ),
      ],
    );
  }
}
