import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_app/screens/add_page.dart';
import 'package:http/http.dart' as http;

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo List"),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: Center(
          child: CircularProgressIndicator(),
        ),
        child: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(item['title']),
                  subtitle: Text(item['description']),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        NavigateToEditPage(item);
                      } else if (value == "delete") {
                        deleteById(id);
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Text('Edit'),
                          value: 'edit',
                        ),
                        PopupMenuItem(
                          child: Text('Delete'),
                          value: 'delete',
                        ),
                      ];
                    },
                  ),
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: NavigateToAddPage,
        label: Text("Add todo"),
      ),
    );
  }

  Future<void> NavigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddToDoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> NavigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => AddToDoPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    // delete item
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      showErrorMessage('Deletion Failed..');
    }
    // remove item
  }

  Future<void> fetchTodo() async {
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;

      setState(() {
        items = result;
        //isLoading = true;
      });
    }
  }
  // setState(() {
  //   isLoading = false;
  // });

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
