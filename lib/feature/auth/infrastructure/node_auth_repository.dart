import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/node/node_api_client.dart';
import '../domain/auth_exception.dart';
import '../domain/entities/app_user.dart';
import '../domain/interfaces/i_auth_repository.dart';

class NodeAuthRepository implements IAuthRepository {
  static const _kToken = 'node_jwt';

  // Populated by restoreSession() before this class is instantiated.
  static AppUser? _restoredUser;

  NodeAuthRepository() {
    _currentUser = _restoredUser;
  }

  final _client = NodeApiClient.instance;
  AppUser? _currentUser;
  final _sessionController = StreamController<AppUser?>.broadcast();

  // ── Static init (call once in main before buildPhase2Dependencies) ──────────

  /// Reads the persisted JWT, validates its expiry, and pre-populates the
  /// session so [currentSession] is non-null immediately after launch.
  static final _storage = const FlutterSecureStorage();

  static Future<void> restoreSession() async {
    final token = await _storage.read(key: _kToken);
    if (token == null) return;

    try {
      final payload = _decodeJwtPayload(token);
      final exp = payload['exp'] as int?;
      if (exp != null && exp * 1000 < DateTime.now().millisecondsSinceEpoch) {
        await _storage.delete(key: _kToken);
        return;
      }
      NodeApiClient.instance.setToken(token);
      _restoredUser = AppUser(
        id: payload['id'] as String,
        email: payload['email'] as String,
      );
    } catch (_) {
      await _storage.delete(key: _kToken);
    }
  }

  static Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw const FormatException('JWT inválido');
    final normalized = base64Url.normalize(parts[1]);
    return jsonDecode(utf8.decode(base64Url.decode(normalized)))
        as Map<String, dynamic>;
  }

  // ── IAuthRepository ──────────────────────────────────────────────────────

  @override
  AppUser? currentSession() => _currentUser;

  @override
  Stream<AppUser?> watchSession() => _sessionController.stream;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _client.post('/api/auth/login', {
        'email': email.trim(),
        'password': password,
      });
      final token = data['token'] as String;
      final userMap = data['user'] as Map<String, dynamic>;

      _client.setToken(token);
      await _storage.write(key: _kToken, value: token);

      _currentUser = AppUser(
        id: userMap['id'] as String,
        email: userMap['email'] as String,
      );
      _restoredUser = _currentUser;
      _sessionController.add(_currentUser);
      return _currentUser!;
    } catch (e) {
      print('Error en NodeAuthRepository.signIn: $e');
      if (e is InvalidCredentialsException || e is ServerAuthException) rethrow;
      final msg = e.toString();
      if (msg.contains('Credenciales incorrectas')) {
        throw const InvalidCredentialsException();
      }
      throw ServerAuthException(msg);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.post('/api/auth/logout', {});
    } catch (_) {}

    await _storage.delete(key: _kToken);
    _client.clearToken();
    _currentUser = null;
    _restoredUser = null;
    _sessionController.add(null);
  }
}
