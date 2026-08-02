import 'package:flutter_test/flutter_test.dart';
import 'package:taoniu/utils/jwe.dart';

void main() {
  group('JweUtil & JweInterceptor Tests', () {
    test('isJweCompact validates 5-part compact strings correctly', () {
      expect(JweUtil.isJweCompact(null), isFalse);
      expect(JweUtil.isJweCompact(''), isFalse);
      expect(JweUtil.isJweCompact('invalid.string'), isFalse);
      expect(JweUtil.isJweCompact('header.key.iv.ciphertext'), isFalse);

      const mockJwe = 'eyJhbGciOiJSU0EtT0FFUC0yNTYiLCJlbmMiOiJBMjU2R0NNIn0.encryptedkey.iv.ciphertext.tag';
      expect(JweUtil.isJweCompact(mockJwe), isTrue);
    });
  });
}
