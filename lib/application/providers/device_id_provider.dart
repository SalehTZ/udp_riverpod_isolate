import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_id_provider.g.dart';

@riverpod
FutureOr<String?> getDeviceId(GetDeviceIdRef ref) async {
  //create an instance of the deviceInfoPlugin
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  //check the device platform
  if (Platform.isAndroid) {
    var deviceInfo = await deviceInfoPlugin.androidInfo;
    return deviceInfo.fingerprint;
  } else if (Platform.isIOS) {
    var deviceInfo = await deviceInfoPlugin.iosInfo;
    return deviceInfo.identifierForVendor;
  } else if (Platform.isLinux) {
    var deviceInfo = await deviceInfoPlugin.linuxInfo;
    return deviceInfo.machineId;
  }
  return 'test';
}
