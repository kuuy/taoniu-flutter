import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taoniu/services/token_refresh_service.dart';
import 'package:taoniu/utils/jwe.dart';

enum WsConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class BinanceSpotWsService {
  static const String wsUrl = 'wss://taoniu.kuuy.com/socket/cryptos/binance/spot';
  static const String defaultTopic = 'binance:spot:tickers';

  WebSocket? _socket;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  final _statusController = StreamController<WsConnectionStatus>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  WsConnectionStatus _currentStatus = WsConnectionStatus.disconnected;
  WsConnectionStatus get currentStatus => _currentStatus;

  Stream<WsConnectionStatus> get statusStream => _statusController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  final Set<String> _subscribedSymbols = {};
  Set<String> get subscribedSymbols => _subscribedSymbols;

  bool _isDisposed = false;

  void _setStatus(WsConnectionStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  Future<void> connect({bool isRetry = false}) async {
    if (_isDisposed) return;
    if (!isRetry && (_currentStatus == WsConnectionStatus.connecting || _currentStatus == WsConnectionStatus.connected)) {
      return;
    }

    _setStatus(WsConnectionStatus.connecting);
    _reconnectTimer?.cancel();

    // Close any previous socket cleanly
    try {
      _socket?.close();
    } catch (_) {}
    _socket = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('ACCESS_TOKEN') ?? '';

      final headers = <String, String>{};
      if (accessToken.isNotEmpty) {
        headers['Authorization'] = 'Taoniu $accessToken';
      }

      if (kDebugMode) {
        print('BinanceSpotWsService: Connecting to $wsUrl ...');
      }

      _socket = await WebSocket.connect(wsUrl, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('WebSocket connection timed out');
        },
      );

      _setStatus(WsConnectionStatus.connected);
      if (kDebugMode) {
        print('BinanceSpotWsService: Connected successfully!');
      }

      // Start ping heartbeat
      _startPingTimer();

      // Listen for incoming messages
      _socket!.listen(
        (data) {
          _onDataReceived(data);
        },
        onError: (error) {
          if (kDebugMode) {
            print('BinanceSpotWsService error: $error');
          }
          _handleDisconnect(WsConnectionStatus.error);
        },
        onDone: () {
          if (kDebugMode) {
            print('BinanceSpotWsService done (code: ${_socket?.closeCode}, reason: ${_socket?.closeReason})');
          }
          _handleDisconnect(WsConnectionStatus.disconnected);
        },
        cancelOnError: true,
      );

      // Resubscribe symbols if any
      if (_subscribedSymbols.isNotEmpty) {
        _sendSubscriptionMessage(action: 'subscribe', symbols: _subscribedSymbols.toList());
      }
    } catch (e) {
      if (kDebugMode) {
        print('BinanceSpotWsService connect exception: $e');
      }

      // Auto refresh token on 401 / 403 / handshake upgrade failure
      if (!isRetry) {
        final errStr = e.toString();
        if (errStr.contains('401') || errStr.contains('403') || errStr.contains('was not upgraded')) {
          if (kDebugMode) {
            print('BinanceSpotWsService: Connection failed (token expired/invalid). Refreshing token...');
          }
          final refreshed = await TokenRefreshService().refreshToken();
          if (refreshed) {
            if (kDebugMode) {
              print('BinanceSpotWsService: Token refreshed! Retrying WebSocket connection...');
            }
            return await connect(isRetry: true);
          }
        }
      }

      _handleDisconnect(WsConnectionStatus.error);
    }
  }

  void _onDataReceived(dynamic data) async {
    try {
      if (data is String) {
        String jsonStr = data;
        if (!data.trim().startsWith('{') && !data.trim().startsWith('[')) {
          try {
            jsonStr = await JweUtil.decrypt(data);
          } catch (e) {
            if (kDebugMode) {
              print('BinanceSpotWsService JWE decrypt error: $e');
            }
          }
        }
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map<String, dynamic>) {
          final action = decoded['action'] ?? decoded['type'] ?? decoded['event'];
          if (action == 'ping') {
            _sendPong();
            return;
          } else if (action == 'pong') {
            return;
          }
          if (!_messageController.isClosed) {
            _messageController.add(decoded);
          }
        } else if (decoded is List) {
          if (!_messageController.isClosed) {
            _messageController.add({'data': decoded});
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('BinanceSpotWsService message decode error: $e');
      }
    }
  }

  Future<void> _sendPong() async {
    if (_socket == null || _currentStatus != WsConnectionStatus.connected) return;
    try {
      final pongStr = jsonEncode({'action': 'pong'});
      final encryptedPong = await JweUtil.encrypt(pongStr);
      _socket!.add(encryptedPong);
    } catch (_) {
      try {
        _socket!.add(jsonEncode({'action': 'pong'}));
      } catch (_) {}
    }
  }

  void subscribe(List<String> symbols) {
    if (symbols.isEmpty) return;
    _subscribedSymbols.addAll(symbols);
    if (_currentStatus == WsConnectionStatus.connected) {
      _sendSubscriptionMessage(action: 'subscribe', symbols: symbols);
    } else {
      connect();
    }
  }

  void unsubscribe(List<String> symbols) {
    if (symbols.isEmpty) return;
    _subscribedSymbols.removeAll(symbols);
    if (_currentStatus == WsConnectionStatus.connected) {
      _sendSubscriptionMessage(action: 'unsubscribe', symbols: symbols);
    }
  }

  Future<void> _sendSubscriptionMessage({required String action, required List<String> symbols}) async {
    if (_socket == null || _currentStatus != WsConnectionStatus.connected) return;

    final payload = {
      'action': action,
      'topic': defaultTopic,
      'symbols': symbols,
    };

    final messageStr = jsonEncode(payload);
    try {
      final encryptedMessage = await JweUtil.encrypt(messageStr);
      if (kDebugMode) {
        print('BinanceSpotWsService TX: $messageStr (Encrypted: $encryptedMessage)');
      }
      _socket!.add(encryptedMessage);
    } catch (e) {
      if (kDebugMode) {
        print('BinanceSpotWsService TX encrypt error: $e');
      }
      // Fallback to sending plain messageStr if encryption fails
      _socket!.add(messageStr);
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) async {
      if (_currentStatus == WsConnectionStatus.connected && _socket != null) {
        try {
          final pingStr = jsonEncode({'action': 'ping'});
          final encryptedPing = await JweUtil.encrypt(pingStr);
          _socket!.add(encryptedPing);
        } catch (_) {
          try {
            _socket!.add(jsonEncode({'action': 'ping'}));
          } catch (_) {}
        }
      }
    });
  }

  void _handleDisconnect(WsConnectionStatus newStatus) {
    _pingTimer?.cancel();
    try {
      _socket?.close();
    } catch (_) {}
    _socket = null;
    _setStatus(newStatus);

    if (!_isDisposed) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!_isDisposed && _currentStatus != WsConnectionStatus.connected) {
        if (kDebugMode) {
          print('BinanceSpotWsService: Attempting auto-reconnect...');
        }
        connect(isRetry: true);
      }
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    if (_socket != null && _subscribedSymbols.isNotEmpty) {
      try {
        _sendSubscriptionMessage(action: 'unsubscribe', symbols: _subscribedSymbols.toList());
      } catch (_) {}
    }
    try {
      _socket?.close();
    } catch (_) {}
    _socket = null;
    _setStatus(WsConnectionStatus.disconnected);
  }

  void dispose() {
    _isDisposed = true;
    disconnect();
    _statusController.close();
    _messageController.close();
  }
}
