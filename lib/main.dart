import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:myreminder/modules/todo.dart'; // Todoクラスのインポート

void main() async{

  // hiveの初期化
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter()); // Todoクラスのアダプタを登録
  await Hive.openBox<Todo>('todoBox'); // Boxのオープン

  // TODOアプリの初期化
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'TODO App'),
    );
  }
}

// TODOアプリのメイン画面
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// TODOアプリの状態管理
class _MyHomePageState extends State<MyHomePage> {
  final Box<Todo> _todoBox = Hive.box<Todo>('todoBox');

  void _addTodo(Todo todo) {
    _todoBox.add(todo);
    setState(() {});
  }

  void _removeTodo(int index) {
    _todoBox.deleteAt(index);
    setState(() {});
  }

  void _toggleDone(int index) {
    Todo todo = _todoBox.getAt(index)!;
    todo.isDone = !todo.isDone;
    todo.save();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ValueListenableBuilder(
        valueListenable: _todoBox.listenable(),
        builder: (context, Box<Todo> box, _) {
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              return TodoCard(
                todo: box.getAt(index)!,
                onToggle: () => _toggleDone(index),
                onRemove: () => _removeTodo(index),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true, // 画面半分よりも大きなモーダルの表示設定
          builder: (BuildContext context) {
            return AddTodoModal(onAdd: _addTodo);
        }),
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
  State<AddTodoModal> createState() => _AddTodoModalState();
}

class _AddTodoModalState extends State<AddTodoModal> {
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  DateTime? _selectedDate;

  bool isDispayKeybord = false;
  final FocusNode _focusTitle = FocusNode();

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
  void initState() {
    super.initState();
    _focusTitle.addListener(() => _onFocusChange(_focusTitle));
  }

  void _onFocusChange(FocusNode focus) {
    setState(() {
      if (focus.hasFocus) {
        isDispayKeybord = true;
      } else {
        isDispayKeybord = false;
      }
    });
  }  

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isDispayKeybord // キーボードの有無により、モーダルのサイズを設定
          ? MediaQuery.of(context).size.height * 0.8
          : MediaQuery.of(context).size.height * 0.5,
      child: Column(
        children: [

          Padding(padding: const EdgeInsets.all(20.0),
            child: TextField(
              focusNode: _focusTitle,
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'TODOタイトル',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
          ),

          Padding(padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: 'TODOリンク (任意)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
          ),

          Padding(padding: const EdgeInsets.all(20.0),
            child: TextButton(
              onPressed: _pickDate,
              child: Text(_selectedDate == null ? '期限を選択' : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
            ),
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