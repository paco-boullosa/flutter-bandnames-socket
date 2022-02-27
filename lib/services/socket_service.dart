import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// enumerador para identificar el estado del servidor
enum ServerStatus { Online, Offline, Connecting }

const String _SERVER_URL = 'http://192.168.1.80';
const String _SERVER_PORT = '3000';

class SocketService with ChangeNotifier {
  // ChangeNotifier ayuda a decirle Provider cuando tiene que refrescar el UI o redibujar algun widget

  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket? _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket!;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    _socket = IO.io(
        '$_SERVER_URL:$_SERVER_PORT',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect() // por defecto ya es true
            .build());

    _socket!.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
      // socket.emit('mensaje', 'conectado desde app Flutter');
    });

    _socket!.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    _socket!.on('nuevo-mensaje', (payload) {
      // print('nuevo-mensaje: $payload');
      print('nombre:' + payload['nombre']);
      print('mensaje:' + payload['mensaje']);
    });
  }
}
