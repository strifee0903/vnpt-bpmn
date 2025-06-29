import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'socket_config.dart';

class SocketManager with ChangeNotifier {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;

  late IO.Socket _socket;
  bool _isConnected = false;
  bool _isInitialized = false;

  SocketManager._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    final socketUrl = await SocketConfig.getSocketUrl();
    _socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _setupSocketListeners();
    _socket.connect();
    _isInitialized = true;
  }

  void _setupSocketListeners() {
    _socket.onConnect((_) {
      _isConnected = true;
      notifyListeners();
      print('✅ Socket connected');
    });

    _socket.onDisconnect((_) {
      _isConnected = false;
      notifyListeners();
      print('❌ Socket disconnected');
    });

    _socket.onConnectError((error) {
      print('❌ Socket connection error: $error');
      _isConnected = false;
      notifyListeners();
    });

    _socket.onError((error) {
      print('❌ Socket error: $error');
    });
  }

  IO.Socket get socket => _socket;
  bool get isConnected => _isConnected;

  void joinRoom(int roomId) {
    if (_isConnected) {
      _socket.emit('join_room', roomId);
    }
  }

  void leaveRoom(int roomId) {
    if (_isConnected) {
      _socket.emit('leave_room', roomId);
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected) {
      _socket.emit('send_message', message);
    }
  }

  void loadMessages(Map<String, dynamic> params) {
    if (_isConnected) {
      _socket.emit('load_messages', params);
    }
  }

  void disconnect() {
    _socket.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  void reconnect() {
    if (!_isConnected) {
      _socket.connect();
    }
  }
}
