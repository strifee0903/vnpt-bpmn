import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketConfig {
  static const int port = 3000;
  static final String realDevice = dotenv.env['REAL_DEVICE'] ?? 'http://192.168.1.6';
  static const String emulator = 'http://10.0.2.2';

  static Future<String> getSocketUrl() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      final isEmulator = androidInfo.isPhysicalDevice == false ||
          androidInfo.model.toLowerCase().contains('sdk') == true;

      return isEmulator ? '$emulator:$port' : '$realDevice:$port';
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      final isEmulator = iosInfo.isPhysicalDevice == false;

      return isEmulator ? '$emulator:$port' : '$realDevice:$port';
    }

    // fallback
    return '$realDevice:$port';
  }
}
