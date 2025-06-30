import 'package:greenly_app/ui/pages/chat/socket_config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();

  late IO.Socket _socket;
  int? currentRoomId;
  bool _initialized = false;

  factory SocketManager() => _instance;

  SocketManager._internal();

  Future<void> init() async {
    if (_initialized) return;
    final socketUrl = await SocketConfig.getSocketUrl();
    _socket = IO.io(socketUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.connect();

    socket.onDisconnect((_) {
      print('❌ Socket disconnected');
    });

    _initialized = true;
  }

  IO.Socket get socket => _socket;
}
