import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_database/database/todo_db.dart';
import 'package:local_database/model/todo.dart';
import 'package:local_database/widgets/create_todo_widget.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  Future<List<Todo>>? futureTodos;
  final todoDB = TodoDB();
  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  void fetchTodos() {
    setState(() {
      futureTodos = todoDB.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo List'),
      ),
      body: FutureBuilder<List<Todo>>(
        future: futureTodos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasData && snapshot.data != null) {
              final todos = snapshot.data!;
              return todos.isEmpty
                  ? const Center(
                      child: Text(
                        'No Todos..',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: todos.length,
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 12,
                      ),
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        final subTitle = DateFormat('yyyy/MM/dd').format(
                            DateTime.parse(todo.updatedAt ?? todo.createdAt));

                        return ListTile(
                          title: Text(
                            todo.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(subTitle),
                          trailing: IconButton(
                            onPressed: () async {
                              await todoDB.delete(todo.id);
                              fetchTodos();
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => CreateTodoWidget(
                                todo: todo,
                                onSubmit: (title) async {
                                  await todoDB.update(
                                      id: todo.id, title: title);
                                  fetchTodos();
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
            } else {
              return const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => CreateTodoWidget(
              onSubmit: (title) async {
                await todoDB.create(title: title);
                if (!mounted) return;
                fetchTodos();
                Navigator.of(context).pop();
              },
            ),
          );
        },
      ),
    );
  }
}
