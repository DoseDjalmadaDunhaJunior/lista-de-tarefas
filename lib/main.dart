import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:path_provider/path_provider.dart";

void main() {
  runApp(MaterialApp(
    home: tudo(),
  ));
}


// ignore: camel_case_types
class tudo extends StatefulWidget {
  const tudo({Key? key}) : super(key: key);

  @override
  _tudoState createState() => _tudoState();
}

// ignore: camel_case_types
class _tudoState extends State<tudo> {

  final _toDoController = TextEditingController();

  List _toDo = [];
  late Map<String, dynamic> _lastRemoved;
  late int _removido;

  @override
  void initState() {
    super.initState();
    _readData().then((data){
      setState(() {
        _toDo = json.decode(data!);
      });
    });
  }

  void _addToDo(){
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["ok"] = false;
      _toDo.add(newToDo);
      _savedata();
    });
  }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDo.sort((a,b){
        if(a["ok"] && !b["ok"]){
          return 1;
        }
        else if(!a["ok"] && b["ok"]){
          return -1;
        }
        else{
          return 0;
        }
      });
      _savedata();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(child:
                TextField(
                  controller: _toDoController,
                  decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.black)
                  ),
                )
                ),
                // ignore: deprecated_member_use
                RaisedButton(
                color: Colors.black,
                child: Text("ADD"),
                textColor: Colors.white,
                onPressed: _addToDo,)
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top:10.0),
                  itemCount: _toDo.length,
                  itemBuilder: buildItem),),
          )
        ],
      ),
    );
  }

  Widget buildItem(context, index){
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9,0.0),
          child: Icon(Icons.delete, color: Colors.white,),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDo[index]["title"]),
        value: _toDo[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDo[index]["ok"] ?
          Icons.check: Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            _toDo[index]["ok"] = c;
            _savedata();
          });
        },
      ),
      onDismissed: (direction){
        setState(() {
          _lastRemoved = Map.from(_toDo[index]);
          _removido = index;
          _toDo.removeAt(index);

          _savedata();

          final snack = SnackBar(
              content: Text("Tarefa \"${_lastRemoved["title"]}\" removida"),
            action: SnackBarAction(label: "Desfazer",
            onPressed: (){
              setState(() {
                _toDo.insert(_removido, _lastRemoved);
                _savedata();
              });
            }),
            duration: Duration(seconds: 2),
          );
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async{
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _savedata() async{
    String data = json.encode(_toDo);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String?> _readData() async{
    try{
      final file = await _getFile();
      return file.readAsString();
    }catch (e){
      return null;
    }
  }
}

