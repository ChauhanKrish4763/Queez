import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

enum ConnectionStatus { connected, disconnected, reconnecting }

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<ConnectionStatus> _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<ConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final List<int> _backoffDelays = [0, 1, 2, 4, 8, 16, 30];

  String? _lastSessionCode;
  String? _lastUserId;

  Future<void> connect(String sessionCode, String userId) async {
    _lastSessionCode = sessionCode;
    _lastUserId = userId;
    _reconnectAttempts = 0;
    await _connect(sessionCode, userId);
  }

  Future _connect(String sessionCode, String userId) async {
    // For Android emulator use 10.0.2.2, for iOS/Web use localhost
    final host =
        defaultTargetPlatform == TargetPlatform.android
            ? '10.0.2.2'
            : 'localhost';

    // Clean session code and user ID - remove any special characters
    final cleanSessionCode = sessionCode.trim();
    final cleanUserId = userId.trim();

    // Construct URI properly - NO trailing characters
    final uri = Uri.parse(
      'ws://$host:8000/api/ws/$cleanSessionCode?user_id=$cleanUserId',
    );

    debugPrint('🔌 Connecting to WebSocket: $uri'); // Debug log

    try {
      if (_reconnectAttempts > 0) {
        _connectionStatusController.add(ConnectionStatus.reconnecting);
      }

      _channel = IOWebSocketChannel.connect(
        uri,
        connectTimeout: const Duration(seconds: 10), // Add timeout
      );

      await _channel!.ready;

      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionStatusController.add(ConnectionStatus.connected);

      debugPrint('✅ WebSocket connected successfully');

      _channel!.stream.listen(
        (message) {
          final decodedMessage = jsonDecode(message);
          _messageController.add(decodedMessage);
        },
        onDone: () {
          debugPrint('⚠️ WebSocket connection closed');
          _isConnected = false;
          _handleDisconnect();
        },
        onError: (error) {
          debugPrint('❌ WebSocket error: $error');
          _isConnected = false;
          _handleDisconnect();
        },
      );
    } catch (e) {
      debugPrint('❌ WebSocket connection failed: $e');
      _isConnected = false;
      _handleDisconnect();
      rethrow;
    }
  }

  void sendMessage(String type, [Map<String, dynamic>? payload]) {
    if (_channel != null && _isConnected) {
      final message = {'type': type, if (payload != null) 'payload': payload};
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _isConnected = false;
      _channel = null;
      _connectionStatusController.add(ConnectionStatus.disconnected);
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _connectionStatusController.add(ConnectionStatus.disconnected);

    if (_lastSessionCode != null && _lastUserId != null) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return;

    if (_reconnectAttempts < _backoffDelays.length) {
      final delay = _backoffDelays[_reconnectAttempts];
      _reconnectAttempts++;

      _reconnectTimer = Timer(Duration(seconds: delay), () {
        if (_lastSessionCode != null && _lastUserId != null) {
          _connect(_lastSessionCode!, _lastUserId!);
        }
      });
    }
  }
}
