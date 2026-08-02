import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('test websocket tickers subscription', () async {
    const token = 'eyJhbGciOiJkaXIiLCJjdHkiOiJKV1QiLCJlbmMiOiJBMTI4R0NNIiwidHlwIjoiSldUIn0..-v1hOj01t4T5twhP.mYVgB5uO4Kl6hvFl1KxabbKtBAufIssk1n3vN-eklIG0-_4gsdoqEMpWa009II8RGdwQyKmVXKzsNC4s_iADLZAMuHKBy7eLXoSRpUoHxwF3Y4HCoU1S_IRdnVsREO-z9I3-wIM45galjcG66lb21roKWkK4_ZxVioZsFly2MHpg_ZB_aaS5tGHY48wJpx_bYlRMCW-U1HtJU7kR383hSubHQ7KIhWl5lLAVc2Sxc7r1NM0fCpFz9OXiPJZiIqzs5FGzokEkFoK00wZjADs_Q1k8FhmBfAFoUhz7FKotSAJjf8elFcyEAgTE6oy_xCafkUwW06SWxmwhAdQ4LmeUd0HR_PncRglGodH0LmK-fNNaAOSZoI6-JiXo4nHEHZAPf1gYc_hh1eRoXznP-VdBfRvzpxROrU-MTJMsAYVJwaiFIZYrjt71dK51yGDzmTpRiPHH_RswpPkpesueoO4TSUP8J_mHwBJ0hVm93OHn0RF9ktWgnv3mz33VqqT1P-gilH7tK7OwU0aM8wVnQh7hDhFfDF24TReZJ3p-BjPKg9jB1cCnzWBZpHl8_UH-Lk2lm7cKMQdprLdtUDfyKgSt7_A-.QxlsrdmEvhVkFCdWLSYEYQ';

    final url = 'wss://taoniu.kuuy.com/socket/cryptos/binance/spot';
    print('Connecting to $url...');

    try {
      final ws = await WebSocket.connect(
        url,
        headers: {
          'Authorization': 'Taoniu $token',
        },
      );
      print('Connected to WebSocket successfully!');

      final completer = Completer<void>();

      ws.listen((data) {
        print('RECEIVED WS DATA: $data');
        if (!completer.isCompleted) completer.complete();
      }, onError: (err) {
        print('WS Error: $err');
      }, onDone: () {
        print('WS Done (code ${ws.closeCode}, reason: ${ws.closeReason})');
      });

      final subMsg = jsonEncode({
        "action": "subscribe",
        "topic": "binance:spot:tickers",
        "symbols": [
          "BTCUSDT",
          "BNBUSDT",
          "ETHUSDT",
          "SOLUSDT",
          "DEXEUSDT"
        ]
      });
      print('Sending subscribe message: $subMsg');
      ws.add(subMsg);

      await Future.any([
        completer.future,
        Future.delayed(const Duration(seconds: 10)),
      ]);

      await ws.close();
    } catch (e) {
      print('Connect Exception: $e');
    }
  });
}
