import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;

  const AddTodoPage({
    Key? key,
    this.todo,
  }) : super(key: key);

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todo = widget.todo;
    if(widget.todo!=null)
      {
       isEdit = true;
       final title = todo ?['title'];
       final description = todo ?['description'];
       titleController.text = title;
       descriptionController.text = description;


      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit? "Edit ToDo":"Add ToDo"),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Title',
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: 'Description'),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              isEdit? updateData() :submitData();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(isEdit?'Update':'Submit'),
            ),
          ),
        ],
      ),
    );
  }

  void updateData() async{
    final todo = widget.todo;
    final id = todo?['_id'];

    //Get Data From Form
    final title = titleController.text;
    final description = descriptionController.text;

    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };
    //Submit Data to the server
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    //show Success or fail message based on status
    if (response.statusCode == 200) {
      showSuccessMessage('Updation Successful');
      log('Updation Successful');
    } else {
      showErrorMessage('Updation Failed');
      log('Updation Failed');
      log(response.body);
    }
  }

  void submitData() async {
    //Get Data From Form
    final title = titleController.text;
    final description = descriptionController.text;

    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };
    //Submit Data to the server
    final url = "https://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    //show Success or fail message based on status
    if (response.statusCode == 201) {
      showSuccessMessage('Creation Successful');
      log('Creation Successful');
    } else {
      showErrorMessage('Creation Failed');
      log('Creation Failed');
      log(response.body);
    }
  }

  //Update Button

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
