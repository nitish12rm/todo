import 'package:flutter/material.dart';
import 'package:todo/screens/todolist_screen.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ToDoList(),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}


