import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controllerTodo = TextEditingController();
  late var _todoList = [];
  late Map<String, dynamic> _lastRemoved;
  late int _lastRemovedIndex;

  @override
  void initState() {
    super.initState();
    _getData().then((data) {
      setState(() {
        _todoList = jsonDecode(data);
      });
    });
  }

  void _addTodo() {
    if (controllerTodo.text.isEmpty) {
      return;
    }
    setState(() {
      Map<String, dynamic> newTodo = {};
      newTodo["title"] = controllerTodo.text;
      newTodo["done"] = false;
      controllerTodo.clear();
      _todoList.add(newTodo);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controllerTodo,
                    decoration: const InputDecoration(
                      labelText: "Tarefa",
                      labelStyle: TextStyle(
                        color: Colors.blueAccent,
                      ),
                    ),
                    onSubmitted: (value) => _addTodo(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _addTodo(),
                  child: const Text(
                    "ADD",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
            onRefresh: _refreshList,
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: buildListItem,
            ),
          ))
        ],
      ),
    );
  }

  Future<File> _getFile() async {
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    return File("${appDocumentsDir.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _getData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return '';
    }
  }

  Widget buildListItem(BuildContext context, int index) {
    return Dismissible(
      key: Key("key_${DateTime.now().millisecondsSinceEpoch}"),
      background: Container(
        color: Colors.red.shade400,
        child: const Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: _buildCheckItem(context, index),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastRemovedIndex = index;
          _todoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _todoList.insert(_lastRemovedIndex, _lastRemoved);
                    _saveData();
                  });
                }),
            duration: const Duration(seconds: 2),
          );

          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Widget _buildCheckItem(BuildContext context, int index) {
    return CheckboxListTile(
      title: Text(_todoList[index]["title"]),
      value: _todoList[index]["done"],
      secondary: CircleAvatar(
        backgroundColor: _todoList[index]["done"]
            ? Colors.green.shade300
            : Colors.blueAccent,
        child: Icon(
          _todoList[index]["done"] ? Icons.check : Icons.pending_outlined,
          color: Colors.white,
        ),
      ),
      onChanged: (checked) {
        setState(() {
          _todoList[index]["done"] = checked;
          _saveData();
        });
      },
    );
  }

  Future<void> _refreshList() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _todoList.sort((a, b) {
        if (a["done"] && !b["done"]) {
          return 1;
        } else if (!a["done"] && b["done"]) {
          return -1;
        } else {
          return 0;
        }
      });
      _saveData();
    });
  }
}
