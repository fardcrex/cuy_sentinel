import 'package:flutter_test/flutter_test.dart';

import 'package:cuy_sentinel/feature/users/domain/entities/panel_user.dart';
import 'package:cuy_sentinel/feature/users/domain/entities/user_access_log.dart';
import 'package:cuy_sentinel/feature/users/domain/entities/user_presence.dart';
import 'package:cuy_sentinel/presentation/users/user_model.dart';
import 'package:cuy_sentinel/presentation/widgets/user_list_tile.dart';

PanelUser _user() => PanelUser(
  id: 'usr-1',
  email: 'test@test.com',
  displayName: 'Testing',
  role: UserRole.viewer,
  createdAt: DateTime(2026, 5, 23),
);

UserAccessLog _log({
  required String id,
  required UserAccessAction action,
  required DateTime timestamp,
}) => UserAccessLog(
  id: id,
  userId: 'usr-1',
  displayName: 'Testing',
  action: action,
  timestamp: timestamp,
  deviceName: 'Chrome · macOS',
  devicePlatform: 'chrome',
);

void main() {
  group('UserModelX', () {
    test('does not show a device whose latest access log is logout', () {
      final model = _user().toModel(
        0,
        allLogs: [
          _log(
            id: 'login',
            action: UserAccessAction.login,
            timestamp: DateTime(2026, 5, 23, 10),
          ),
          _log(
            id: 'logout',
            action: UserAccessAction.logout,
            timestamp: DateTime(2026, 5, 23, 11),
          ),
        ],
      );

      expect(model.devices, isEmpty);
      expect(model.onlineStatus, UserOnlineStatus.offline);
    });

    test('marks user as away when all current presences are away', () {
      final model = _user().toModel(
        0,
        presences: const [
          UserPresence(
            userId: 'usr-1',
            deviceName: 'Chrome · macOS',
            devicePlatform: 'chrome',
            status: UserPresenceStatus.away,
          ),
        ],
      );

      expect(model.onlineStatus, UserOnlineStatus.away);
      expect(model.devices.single.isAway, isTrue);
    });
  });
}
