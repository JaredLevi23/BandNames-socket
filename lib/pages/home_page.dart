import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id:'1', name: 'Metallica', votes: 10),
    Band(id:'2', name: 'Queen', votes: 10),
    Band(id:'3', name: 'Bad bunny', votes: 10),
    Band(id:'4', name: 'Anuel aa', votes: 10),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('BandNames Votes', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
      ),

      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, indice) => _bandTile(bands[indice])
      ),
      
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( direction ){
        //TODO: Llamar el borrado del server

        print('direction: $direction');
        print('id: ${band.id}');
      },
      background: Container(
        padding: const EdgeInsets.only(left: 20),
        color: Colors.red,
        child: const Align(
          child: Text('Eliminando', style: TextStyle(color: Colors.white),),
          alignment: Alignment.centerLeft,
        ),
      ),
      child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(band.name.substring(0,2)),
            ),
            title: Text(band.name),
            trailing: Text('${band.votes}'),
            onTap: (){
              print(band.name);
            },
          ),
    );
  }


  addNewBand(){

    final textController = TextEditingController();

    if( Platform.isAndroid ){
      //Android
      showDialog(
        context: context, 
        builder: (context){
          return AlertDialog(
            title: const Text('New Band name:'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                textColor: Colors.blue,
                child: const Text('Add'),
                onPressed: (){
                  addBandToList(textController.text);
                }
              ),
              MaterialButton(
                textColor: Colors.red,
                child: const Text('Cancelar'),
                onPressed: (){
                      Navigator.of(context).pop();
                }
              )
            ],
          );
        }
      );
    }else{

      showCupertinoDialog(
        context: context, 
        builder: (context){
          return CupertinoAlertDialog(
              title: const Text('New Band name:'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Add'),
                  onPressed: (){
                    addBandToList(textController.text);
                  }
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: const Text('Dismiss'),
                  onPressed: (){
                    Navigator.pop(context);
                  }
                ),
              ],
          );
        }
      );
    }

    
  }


  void addBandToList(String name){

    if(name.length>1){
      //Se agrega
      print(name);
      this.bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {
        
      });
    }

    Navigator.of(context).pop();

  }
}