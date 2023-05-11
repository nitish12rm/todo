import 'dart:convert';
import 'dart:developer';
import 'add_todo_screen.dart';
import 'package:flutter/material.dart';
import 'package:todo/screens/add_todo_screen.dart';
import 'package:http/http.dart' as http;

class ToDoList extends StatefulWidget {
  const ToDoList({Key? key}) : super(key: key);

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchToDo();
  }

  Widget build(BuildContext context) {
    return Visibility(
      visible: isLoading,
      child: Center(
        child: CircularProgressIndicator(),
      ),
      replacement: RefreshIndicator(
        onRefresh: fetchToDo,
        child: Scaffold(
          appBar: AppBar(
            title: Text('ToDo List'),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              navigateToAddPage();
            },
            label: Text('Add ToDo'),
            elevation: 3,
          ),
          body: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
                child: Text(
              "No ToDo item",
              style: Theme.of(context).textTheme.displaySmall,
            )),
            child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  final id = item['_id'] as String;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(item['title']),
                      subtitle: Text(
                        item['description'],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              child: Text('Edit'),
                              value: 'edit',
                            ),
                            PopupMenuItem(
                              child: Text('Delete'),
                              value: 'delete',
                            )
                          ];
                        },
                        onSelected: (value) {
                          if (value == 'edit') {
                            //Open Edit Page
                            navigateToEditPage(item);
                          }
                          if (value == 'delete') {
                            //Delete the task//
                            deleteToDo(id);
                          }
                        },
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }

  Future<void> navigateToEditPage(Map item) async {
    final AddPageroute =
        MaterialPageRoute(builder: (context) => AddTodoPage(todo: item));
    await Navigator.push(context, AddPageroute);
    setState(() {
      isLoading = true;
    });

    fetchToDo();
  }

  Future<void> navigateToAddPage() async {
    final AddPageroute = MaterialPageRoute(builder: (context) => AddTodoPage());
    await Navigator.push(context, AddPageroute);
    setState(() {
      isLoading = true;
    });
    fetchToDo();
  }

  //to GET all the data that is saved on server
  Future<void> fetchToDo() async {
    final url = "https://api.nstack.in/v1/todos?page=1&limit=10";
    final uri = Uri.parse(url);

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteToDo(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);

    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      //remove an item from the list
      // we will update the list by showing all other items except the item we deleted

      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
      showSuccessMessage('Deleted!');
    } else {
      //show error
      log(response.statusCode.toString());
      showErrorMessage('Deletion Failed');
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
