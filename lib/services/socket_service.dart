import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }
 
class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;


  late IO.Socket _socket;
  ServerStatus get serverStatus => _serverStatus;
 
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;
 
  SocketService(){
    _initConfig();
  }

  void _initConfig() {
    String urlSocket = 'https://flutter-socket.herokuapp.com/'; //tu ipv4 con iPconfig (windows)
    //String urlSocket = 'http://192.168.100.5:3000'; //tu ipv4 con iPconfig (windows)
 
    _socket = IO.io(
        urlSocket,
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableAutoConnect()
            .setExtraHeaders({'foo': 'bar'}) // optional
            .build());
 
    // Estado Conectado
    _socket.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      print('Conectado por Socket');
      notifyListeners();
    });
 
    // Estado Desconectado
    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
      print('Desconectado del Socket Server');
      notifyListeners();
    });

    // _socket.on('nuevo-mensaje',( payload ) {

    //   print('nuevo-mensaje: $payload');
    //   print('nombre: '+ payload['nombre']);
    //   print('mensaje: '+ payload['mensaje']);

    //   print( payload.containsKey('mensaje2') ? payload['mensaje2'] : 'no hay' );
    // });

    

  }
}