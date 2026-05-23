import 'package:flutter_test/flutter_test.dart';
import 'package:cuy_sentinel/core/services/device_info_service.dart';

void main() {
  group('InMemoryDeviceInfoService', () {
    test('returns fixed web device info', () async {
      final service = InMemoryDeviceInfoService();
      final info = await service.getDeviceInfo();
      expect(info.deviceName, isNotEmpty);
      expect(info.devicePlatform, 'web');
    });
  });
}
