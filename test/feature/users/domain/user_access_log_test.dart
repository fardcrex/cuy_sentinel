import 'package:flutter_test/flutter_test.dart';
import 'package:cuy_sentinel/feature/users/domain/entities/user_access_log.dart';

void main() {
  group('UserAccessLog', () {
    final baseJson = {
      'id': 'log-1',
      'user_id': 'usr-1',
      'display_name': 'Jair',
      'action': 'login',
      'timestamp': '2026-05-23T10:00:00.000Z',
      'ip_address': null,
    };

    test('fromJson maps deviceName and devicePlatform when present', () {
      final json = {...baseJson, 'device_name': 'Chrome 124 · macOS Sonoma', 'device_platform': 'web'};
      final log = UserAccessLog.fromJson(json);
      expect(log.deviceName, 'Chrome 124 · macOS Sonoma');
      expect(log.devicePlatform, 'web');
    });

    test('fromJson treats missing device fields as null', () {
      final log = UserAccessLog.fromJson(baseJson);
      expect(log.deviceName, isNull);
      expect(log.devicePlatform, isNull);
    });

    test('toJson includes deviceName and devicePlatform', () {
      final log = UserAccessLog(
        id: 'log-1', userId: 'usr-1', displayName: 'Jair',
        action: UserAccessAction.login,
        timestamp: DateTime.utc(2026, 5, 23, 10),
        deviceName: 'Pixel 7 · Android 14',
        devicePlatform: 'android',
      );
      final json = log.toJson();
      expect(json['device_name'], 'Pixel 7 · Android 14');
      expect(json['device_platform'], 'android');
    });

    test('toJson uses null for missing device fields', () {
      final log = UserAccessLog(
        id: 'log-1', userId: 'usr-1', displayName: 'Jair',
        action: UserAccessAction.login,
        timestamp: DateTime.utc(2026, 5, 23, 10),
      );
      final json = log.toJson();
      expect(json['device_name'], isNull);
      expect(json['device_platform'], isNull);
    });
  });
}
