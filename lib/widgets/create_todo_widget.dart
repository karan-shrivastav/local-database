import 'package:flutter/material.dart';
import 'package:local_database/model/todo.dart';

class CreateTodoWidget extends StatefulWidget {
  final Todo? todo;
  final ValueChanged<String> onSubmit;

  const CreateTodoWidget({
    super.key,
    this.todo,
    required this.onSubmit,
  });

  @override
  State<CreateTodoWidget> createState() => _CreateTodoWidgetState();
}

class _CreateTodoWidgetState extends State<CreateTodoWidget> {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller.text = widget.todo?.title ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todo != null;
    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Todo' : 'Add Todo',
      ),
      content: Form(
        key: formKey,
        child: TextFormField(
          autofocus: true,
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Title',
          ),
          validator: (value) =>
              value != null && value.isNotEmpty ? 'Title is required' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSubmit(controller.text);
          },
          child: const Text('OK'),
        )
      ],
    );
  }
}