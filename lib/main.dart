import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'TODO App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Todo> _todoList = [];

  void _addTodo(Todo todo) {
    setState(() {
      _todoList.add(todo);
    });
  }

  void _removeTodo(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
  }

  void _toggleDone(int index) {
    setState(() {
      _todoList[index].isDone = !_todoList[index].isDone;
    });
  }

  void _showAddTodoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddTodoModal(onAdd: _addTodo);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Expanded(
        child: TodoList(
          todos: _todoList,
          onToggle: _toggleDone,
          onRemove: _removeTodo,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final Function(int) onToggle;
  final Function(int) onRemove;

  const TodoList({
    super.key,
    required this.todos,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return TodoCard(
          todo: todos[index],
          onToggle: () => onToggle(index),
          onRemove: () => onRemove(index),
        );
      },
    );
  }
}

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.link.isNotEmpty)
              Text("Link: ${todo.link}", style: TextStyle(color: Colors.blue)),
            if (todo.deadline != null)
              Text("Deadline: ${DateFormat('yyyy-MM-dd').format(todo.deadline!)}"),
          ],
        ),
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (_) => onToggle(),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onRemove,
        ),
      ),
    );
  }
}

class AddTodoModal extends StatefulWidget {
  final Function(Todo) onAdd;

  const AddTodoModal({super.key, required this.onAdd});

  @override
  _AddTodoModalState createState() => _AddTodoModalState();
}

class _AddTodoModalState extends State<AddTodoModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  DateTime? _selectedDate;

  void _submit() {
    if (_titleController.text.isNotEmpty) {
      widget.onAdd(Todo(
        title: _titleController.text,
        link: _linkController.text,
        deadline: _selectedDate,
      ));
      Navigator.pop(context);
    }
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'TODOタイトル'),
          ),
          TextField(
            controller: _linkController,
            decoration: const InputDecoration(labelText: 'リンク (任意)'),
          ),
          TextButton(
            onPressed: _pickDate,
            child: Text(_selectedDate == null ? '期限を選択' : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
          ),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }
}

class Todo {
  String title;
  String link;
  DateTime? deadline;
  bool isDone;

  Todo({required this.title, this.link = '', this.deadline, this.isDone = false});
}