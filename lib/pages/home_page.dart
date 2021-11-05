import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  @override
  void initState() {
    // TODO: implement initState
    final sockedService = Provider.of<SocketService>(context, listen: false);

    sockedService.socket.on('active-bands', _handleActiveBands );
    super.initState();
  }

  _handleActiveBands( dynamic payload ){
    bands = (payload as List)
      .map(( band ) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final sockedService = Provider.of<SocketService>(context, listen: false);
    sockedService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final sockedService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('BandNames Votes', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: sockedService.serverStatus == ServerStatus.Online 
            ? Icon(Icons.check_circle, color: Colors.blue[300])
            : const Icon(Icons.offline_bolt,color: Colors.red),
          )
        ],
      ),

      body: Column(

        children: [

          if(bands.isEmpty)
            Container()
          else
            _showGraph(),
          

          const SizedBox(height: 15,),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, indice) => _bandTile(bands[indice])
            ),
          )
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {

    final sockerService = Provider.of<SocketService>(context);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ )=>sockerService.emit('delete-band', {'id': band.id}),
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
            onTap: () => sockerService.emit('vote-band', { 'id': band.id })
          ),
    );
  }


  addNewBand(){

    final textController = TextEditingController();

    if( Platform.isAndroid ){
      //Android
      showDialog(
        context: context, 
        builder: ( _ ) => AlertDialog(
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
          )
      );
    }else{

      showCupertinoDialog(
        context: context, 
        builder: ( _ ) => CupertinoAlertDialog(
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
          )
      );
    }

    
  }


  void addBandToList(String name){

    final socketService = Provider.of<SocketService>(context, listen: false);

    if(name.length>1){
      //Se agrega
      socketService.emit('add-band', { 'name': name });
    }

    Navigator.of(context).pop();

  }

  Widget _showGraph(){

    late Map<String, double> dataMap = {
    };

    for (var element in bands) { 
      dataMap.putIfAbsent(element.name, () => element.votes.toDouble());
    }
    

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: PieChart(
        dataMap: dataMap,

      )
      );
  }
}