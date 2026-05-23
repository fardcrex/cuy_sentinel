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
    final browserKey = _browserPlatformKey(info.browserName.name);
    final browser = _browserLabel(browserKey);
    final os = _osFromUserAgent(info.userAgent ?? '');
    return (deviceName: '$browser · $os', devicePlatform: browserKey);
  }

  Future<({String deviceName, String devicePlatform})> _androidInfo() async {
    final info = await _plugin.androidInfo;
    return (deviceName: info.model, devicePlatform: 'android');
  }

  Future<({String deviceName, String devicePlatform})> _iosInfo() async {
    final info = await _plugin.iosInfo;
    final modelName = info.modelName.trim().isNotEmpty
        ? info.modelName
        : info.model;
    return (deviceName: modelName, devicePlatform: 'ios');
  }

  Future<({String deviceName, String devicePlatform})> _macOsInfo() async {
    final info = await _plugin.macOsInfo;
    final modelName = info.modelName.trim().isNotEmpty
        ? info.modelName
        : info.model;
    return (
      deviceName: '${info.computerName} · $modelName',
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

  String _browserPlatformKey(String browserName) => switch (browserName) {
    'chrome' => 'chrome',
    'firefox' => 'firefox',
    'safari' || 'mobileSafari' => 'safari',
    'edge' => 'edge',
    'opera' => 'opera',
    'samsungInternet' => 'samsung',
    _ => 'web',
  };

  String _browserLabel(String browserKey) => switch (browserKey) {
    'chrome' => 'Chrome',
    'firefox' => 'Firefox',
    'safari' => 'Safari',
    'edge' => 'Edge',
    'opera' => 'Opera',
    'samsung' => 'Samsung Internet',
    _ => 'Navegador',
  };

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
      (deviceName: 'Chrome · macOS', devicePlatform: 'chrome');
}
