import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddToDoPage extends StatefulWidget {
  final Map? todo;
  const AddToDoPage({super.key, this.todo});

  @override
  State<AddToDoPage> createState() => __AddToDoPageState();
}

class __AddToDoPageState extends State<AddToDoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController decriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    final todo = widget.todo;
    super.initState();
    if (todo != null) {
      isEdit = true;
      final title = todo["title"];
      final description = todo["description"];
      titleController.text = title;
      titleController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit ToDo' : 'Add ToDo'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
                hintText: "Title", border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            controller: decriptionController,
            decoration: InputDecoration(
              hintText: 'Description',
              hintMaxLines: 5,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: isEdit? updateData : submitbutton,
              child: Text(isEdit? "Update" : "Submit"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if(todo == null){
      print('You cannot call updated without todo data');
      return;
    }
    final id = todo['_id'];
    //final isCompleted = todo['is_completed'];
    final title = titleController.text;
    final description = decriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
      //"is_completed": isCompleted,
    };

    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      showSuccessMessage('Updation Sucess');
    } else {
      showSuccessMessage('Updation failed');
    }
  }

  Future<void> submitbutton() async {
    //Get data from the form
    final title = titleController.text;
    final desc = decriptionController.text;
    final body = {
      "title": title,
      "description": desc,
      "is_completed": false,
    };

    //http.post(url)
    //submit the data to the server
    final url = "https://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    //show status on the behaviour of the data stored
    if (response.statusCode == 201) {
      titleController.text = '';
      decriptionController.text = '';
      print('Sucess');
      showSuccessMessage('Creation Sucess');
    } else {
      print('Error');
      print(response.body);
      showSuccessMessage('Creation failed');
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
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.indigoAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
