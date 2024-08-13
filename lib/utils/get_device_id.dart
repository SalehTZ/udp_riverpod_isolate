import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

Future<String?> deviceId() async {
  //create an instance of the deviceInfoPlugin
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  //check the device platform
  if (Platform.isAndroid) {
    var deviceInfo = await deviceInfoPlugin.androidInfo;
    return deviceInfo.id;
  } else if (Platform.isIOS) {
    var deviceInfo = await deviceInfoPlugin.iosInfo;
    return deviceInfo.identifierForVendor;
  } else if (Platform.isLinux) {
    var deviceInfo = await deviceInfoPlugin.linuxInfo;
    return deviceInfo.machineId;
  }
  return 'test';
}
