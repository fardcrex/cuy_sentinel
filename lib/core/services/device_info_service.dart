import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

abstract interface class IDeviceInfoService {
  Future<({String deviceName, String devicePlatform})> getDeviceInfo();
}

class DeviceInfoService implements IDeviceInfoService {
  final _plugin = DeviceInfoPlugin();

  @override
  Future<({String deviceName, String devicePlatform})> getDeviceInfo() async {
    try {
      if (kIsWeb) return _webInfo();
      if (Platform.isAndroid) return _androidInfo();
      if (Platform.isIOS) return _iosInfo();
      if (Platform.isMacOS) return _macOsInfo();
      if (Platform.isWindows) return _windowsInfo();
      if (Platform.isLinux) return _linuxInfo();
    } catch (_) {}
    return (deviceName: 'Dispositivo desconocido', devicePlatform: 'unknown');
  }

  Future<({String deviceName, String devicePlatform})> _webInfo() async {
    final info = await _plugin.webBrowserInfo;
    final browser = _capitalize(info.browserName.name);
    final os = _osFromUserAgent(info.userAgent ?? '');
    return (deviceName: '$browser · $os', devicePlatform: 'web');
  }

  Future<({String deviceName, String devicePlatform})> _androidInfo() async {
    final info = await _plugin.androidInfo;
    return (
      deviceName: '${info.model} · Android ${info.version.release}',
      devicePlatform: 'android',
    );
  }

  Future<({String deviceName, String devicePlatform})> _iosInfo() async {
    final info = await _plugin.iosInfo;
    return (
      deviceName: '${info.model} · iOS ${info.systemVersion}',
      devicePlatform: 'ios',
    );
  }

  Future<({String deviceName, String devicePlatform})> _macOsInfo() async {
    final info = await _plugin.macOsInfo;
    return (
      deviceName: '${info.computerName} · macOS ${info.majorVersion}.${info.minorVersion}',
      devicePlatform: 'macos',
    );
  }

  Future<({String deviceName, String devicePlatform})> _windowsInfo() async {
    final info = await _plugin.windowsInfo;
    return (
      deviceName: '${info.computerName} · Windows ${info.majorVersion}',
      devicePlatform: 'windows',
    );
  }

  Future<({String deviceName, String devicePlatform})> _linuxInfo() async {
    final info = await _plugin.linuxInfo;
    return (deviceName: info.prettyName, devicePlatform: 'linux');
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _osFromUserAgent(String ua) {
    if (ua.contains('Mac OS X')) return 'macOS';
    if (ua.contains('Windows')) return 'Windows';
    if (ua.contains('Android')) return 'Android';
    if (ua.contains('iPhone') || ua.contains('iPad')) return 'iOS';
    if (ua.contains('Linux')) return 'Linux';
    return 'Web';
  }
}

class InMemoryDeviceInfoService implements IDeviceInfoService {
  @override
  Future<({String deviceName, String devicePlatform})> getDeviceInfo() async =>
      (deviceName: 'Chrome 124 · macOS Sonoma', devicePlatform: 'web');
}
