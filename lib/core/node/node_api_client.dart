import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as sio;

import '../env/app_env.dart';

class NodeApiClient {
  NodeApiClient._();
  static final NodeApiClient instance = NodeApiClient._();

  String get _baseUrl =>
      AppEnv.apiBaseUrl.isNotEmpty ? AppEnv.apiBaseUrl : 'http://localhost:3000';

  String? _token;
  sio.Socket? _socket;

  void setToken(String token) {
    _token = token;
    _socket?.disconnect();
    _socket = null;
  }

  void clearToken() {
    _token = null;
    _socket?.disconnect();
    _socket = null;
  }

  String? get token => _token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Uri _uri(String path, [Map<String, String>? params]) {
    final uri = Uri.parse('$_baseUrl$path');
    return params != null ? uri.replace(queryParameters: params) : uri;
  }

  Future<dynamic> get(String path, {Map<String, String>? params}) async {
    final res = await http.get(_uri(path, params), headers: _headers);
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async {
    final res = await http.patch(
      _uri(path),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  void _checkStatus(http.Response res) {
    if (res.statusCode >= 400) {
      Map<String, dynamic> body;
      try {
        body = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception('HTTP ${res.statusCode}');
      }
      throw Exception(body['error'] ?? 'HTTP ${res.statusCode}');
    }
  }

  sio.Socket get socket {
    if (_socket != null) return _socket!;
    _socket = sio.io(
      _baseUrl,
      sio.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setExtraHeaders(
            _token != null ? {'Authorization': 'Bearer $_token'} : {},
          )
          .build(),
    );
    return _socket!;
  }
}
