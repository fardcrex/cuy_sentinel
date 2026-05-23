import '../../../core/services/device_info_service.dart';
import '../../../core/utils/stream_retry.dart';
import '../domain/entities/panel_user.dart';
import '../domain/entities/user_access_log.dart';
import '../domain/interfaces/i_users_repository.dart';

class WatchPanelUsersUseCase {
  const WatchPanelUsersUseCase(this._repository);

  final IUsersRepository _repository;

  Stream<List<PanelUser>> execute({void Function(RetryState)? onRetry}) =>
      _repository.watchUsers(onRetry: onRetry);
}

class GetPanelUsersUseCase {
  const GetPanelUsersUseCase(this._repository);

  final IUsersRepository _repository;

  Future<List<PanelUser>> execute() => _repository.getUsers();
}

class GetAccessLogsUseCase {
  const GetAccessLogsUseCase(this._repository);

  final IUsersRepository _repository;

  Future<List<UserAccessLog>> execute({int limit = 50}) =>
      _repository.getAccessLogs(limit: limit);
}

class WatchAccessLogsUseCase {
  const WatchAccessLogsUseCase(this._repository);

  final IUsersRepository _repository;

  Stream<List<UserAccessLog>> execute({
    int limit = 50,
    void Function(RetryState)? onRetry,
  }) => _repository.watchAccessLogs(limit: limit, onRetry: onRetry);
}

class WatchPresenceUseCase {
  const WatchPresenceUseCase(this._repository);

  final IUsersRepository _repository;

  Stream<Set<String>> execute() => _repository.watchPresence();
}

class TrackPresenceUseCase {
  const TrackPresenceUseCase(this._repository);

  final IUsersRepository _repository;

  Future<void> execute(String userId) => _repository.trackPresence(userId);
}

class UntrackPresenceUseCase {
  const UntrackPresenceUseCase(this._repository);

  final IUsersRepository _repository;

  Future<void> execute() => _repository.untrackPresence();
}

class LogAccessUseCase {
  const LogAccessUseCase(this._repository, this._deviceInfo);

  final IUsersRepository _repository;
  final IDeviceInfoService _deviceInfo;

  Future<void> execute({
    required String userId,
    required String fallbackName,
    required UserAccessAction action,
    required bool loggedIn,
  }) async {
    final (user, device) = await (
      _repository.getUserById(userId),
      _deviceInfo.getDeviceInfo(),
    ).wait;
    final displayName = user?.displayName ?? fallbackName;
    await Future.wait([
      _repository.logAccess(
        userId: userId,
        displayName: displayName,
        action: action,
        deviceName: device.deviceName,
        devicePlatform: device.devicePlatform,
      ),
      _repository.updateSession(userId, loggedIn: loggedIn),
    ]);
  }
}
