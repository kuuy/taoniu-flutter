import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taoniu/http/api_client.dart';
import 'package:taoniu/api/cryptos/binance/spot/analysis/tradings/scalping_api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fetch scalping list', () async {
    // Mock shared preferences
    SharedPreferences.setMockInitialValues({
      'ACCESS_TOKEN': 'eyJhbGciOiJkaXIiLCJjdHkiOiJKV1QiLCJlbmMiOiJBMTI4R0NNIiwidHlwIjoiSldUIn0..-v1hOj01t4T5twhP.mYVgB5uO4Kl6hvFl1KxabbKtBAufIssk1n3vN-eklIG0-_4gsdoqEMpWa009II8RGdwQyKmVXKzsNC4s_iADLZAMuHKBy7eLXoSRpUoHxwF3Y4HCoU1S_IRdnVsREO-z9I3-wIM45galjcG66lb21roKWkK4_ZxVioZsFly2MHpg_ZB_aaS5tGHY48wJpx_bYlRMCW-U1HtJU7kR383hSubHQ7KIhWl5lLAVc2Sxc7r1NM0fCpFz9OXiPJZiIqzs5FGzokEkFoK00wZjADs_Q1k8FhmBfAFoUhz7FKotSAJjf8elFcyEAgTE6oy_xCafkUwW06SWxmwhAdQ4LmeUd0HR_PncRglGodH0LmK-fNNaAOSZoI6-JiXo4nHEHZAPf1gYc_hh1eRoXznP-VdBfRvzpxROrU-MTJMsAYVJwaiFIZYrjt71dK51yGDzmTpRiPHH_RswpPkpesueoO4TSUP8J_mHwBJ0hVm93OHn0RF9ktWgnv3mz33VqqT1P-gilH7tK7OwU0aM8wVnQh7hDhFfDF24TReZJ3p-BjPKg9jB1cCnzWBZpHl8_UH-Lk2lm7cKMQdprLdtUDfyKgSt7_A-.QxlsrdmEvhVkFCdWLSYEYQ',
    });

    await dotenv.load(fileName: '.env');

    try {
      final response = await ScalpingApi.listings(current: 1, pageSize: 50);
      print("Success: \${response.success}");
    } catch (e) {
      print("Caught Error: \$e");
    }
  });
}
