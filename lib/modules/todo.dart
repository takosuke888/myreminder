import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String title;
  
  @HiveField(1)
  String link;
  
  @HiveField(2)
  DateTime? deadline;
  
  @HiveField(3)
  bool isDone;

  Todo({required this.title, this.link = '', this.deadline, this.isDone = false});
}