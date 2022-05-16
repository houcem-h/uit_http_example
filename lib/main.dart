import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './todo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const MyHomePage(title: 'Todo list'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final String url = 'https://jsonplaceholder.typicode.com/todos';
  List<dynamic> _todos = [];
  bool loading = true;


  @override
  void initState() {
    getTodosFromServer();
    super.initState();
  }

  Future<void> getTodosFromServer() async {
    var response = await http.get(Uri.parse(url));
    if(response.statusCode == 200) {
      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
      _todos = parsed.map<Todo>((json) => Todo.fromJson(json)).toList();
      setState(() {
        loading = !loading;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: loading ? waitingScreen() : todosList()
    );
  }

  Widget waitingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Text("Loading data ..."),
          Padding(padding: EdgeInsets.only(bottom: 30)),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget todosList() {
    return ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          Todo todo = _todos[index];
          return Dismissible(
            key: Key(todo.id.toString()),
            child: Card(
              child: ListTile(
                title: Text(
                  todo.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan,
                      fontSize: 20
                  ),
                ),
              ),
            ),
            background: Container(
              child: const Icon(
                Icons.delete,
                size: 40,
                color: Colors.white,
              ),
              color: Colors.cyanAccent,
            ),
            onDismissed: (direction) {
              setState(() {
                _todos.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Car ${todo.id} ${todo.title} deleted !"))
              );
            },
          );
        }
    );
  }
}
