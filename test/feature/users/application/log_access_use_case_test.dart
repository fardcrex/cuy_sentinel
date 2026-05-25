import 'package:cuy_sentinel/core/services/device_info_service.dart';
import 'package:cuy_sentinel/core/utils/stream_retry.dart';
import 'package:cuy_sentinel/feature/users/application/get_users_use_case.dart';
import 'package:cuy_sentinel/feature/users/domain/entities/panel_user.dart';
import 'package:cuy_sentinel/feature/users/domain/entities/user_access_log.dart';
import 'package:cuy_sentinel/feature/users/domain/entities/user_presence.dart';
import 'package:cuy_sentinel/feature/users/domain/interfaces/i_users_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements IUsersRepository {
  String? loggedUserId;
  String? loggedDeviceName;
  String? loggedDevicePlatform;

  final PanelUser? _user;
  _FakeRepo({PanelUser? user}) : _user = user;

  @override
  Future<PanelUser?> getUserById(String id) async => _user;

  @override
  Future<void> logAccess({
    required String userId,
    required String displayName,
    required UserAccessAction action,
    String? deviceName,
    String? devicePlatform,
  }) async {
    loggedUserId = userId;
    loggedDeviceName = deviceName;
    loggedDevicePlatform = devicePlatform;
  }

  @override
  Future<void> updateSession(String userId, {required bool loggedIn}) async {}
  @override
  Stream<List<PanelUser>> watchUsers({void Function(RetryState)? onRetry}) =>
      const Stream.empty();
  @override
  Stream<List<UserAccessLog>> watchAccessLogs({
    int limit = 50,
    void Function(RetryState)? onRetry,
  }) => const Stream.empty();
  @override
  Stream<List<UserPresence>> watchPresence() => const Stream.empty();
  @override
  Future<void> trackPresence({
    required String userId,
    required String deviceName,
    required String devicePlatform,
    UserPresenceStatus status = UserPresenceStatus.active,
  }) async {}
  @override
  Future<void> untrackPresence() async {}
  @override
  Future<List<PanelUser>> getUsers() async => [];
  @override
  Future<List<UserAccessLog>> getAccessLogs({int limit = 50}) async => [];
  @override
  Future<List<UserAccessLog>> getAccessLogsByUser({
    required String userId,
    int limit = 20,
  }) async => [];

  @override
  Future<void> updateUserRole(String userId, UserRole role) {
    throw UnimplementedError();
  }
}

class _FakeDeviceInfo implements IDeviceInfoService {
  final String name;
  final String platform;
  _FakeDeviceInfo({this.name = 'Test Device', this.platform = 'web'});

  @override
  Future<({String deviceName, String devicePlatform})> getDeviceInfo() async =>
      (deviceName: name, devicePlatform: platform);
}

void main() {
  group('LogAccessUseCase', () {
    test('passes deviceName and devicePlatform to repository', () async {
      final repo = _FakeRepo();
      final deviceInfo = _FakeDeviceInfo(
        name: 'Chrome 124 · macOS Sonoma',
        platform: 'web',
      );
      final useCase = LogAccessUseCase(repo, deviceInfo);

      await useCase.execute(
        userId: 'usr-1',
        fallbackName: 'test@example.com',
        action: UserAccessAction.login,
        loggedIn: true,
      );

      expect(repo.loggedDeviceName, 'Chrome 124 · macOS Sonoma');
      expect(repo.loggedDevicePlatform, 'web');
    });

    test('uses displayName from repo when user found', () async {
      final user = PanelUser(
        id: 'usr-1',
        email: 'jair@test.com',
        displayName: 'Jair Conislla',
        role: UserRole.admin,
        createdAt: DateTime(2025),
      );
      final repo = _FakeRepo(user: user);
      final useCase = LogAccessUseCase(repo, _FakeDeviceInfo());

      await useCase.execute(
        userId: 'usr-1',
        fallbackName: 'jair@test.com',
        action: UserAccessAction.login,
        loggedIn: true,
      );

      expect(repo.loggedUserId, 'usr-1');
    });

    test('falls back to email when user not found in repo', () async {
      final repo = _FakeRepo(user: null);
      final useCase = LogAccessUseCase(repo, _FakeDeviceInfo());

      await expectLater(
        useCase.execute(
          userId: 'usr-x',
          fallbackName: 'ghost@test.com',
          action: UserAccessAction.logout,
          loggedIn: false,
        ),
        completes,
      );
      expect(repo.loggedUserId, 'usr-x');
    });
  });
}
