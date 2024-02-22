import 'package:flutter/material.dart';
import 'package:smattodo/src/repository/repository.dart';
import 'package:smattodo/src/screens/todolistscreen.dart';

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  final TaskRepository taskRepository;

  MyApp({required this.taskRepository, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoListScreen(todoListViewModel: taskRepository),
    );
  }
}
