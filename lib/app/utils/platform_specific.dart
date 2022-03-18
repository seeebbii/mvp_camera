import 'package:flutter/services.dart';

class PlatformSpecific{
  static const MethodChannel _channel = MethodChannel('camera-app');

  void openDirectoryLocation(String projectName) async {
    String data = await _channel.invokeMethod("openMyFiles", {"path":projectName});
    print(data);
  }

}