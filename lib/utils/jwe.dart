import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jose/jose.dart';

class JweUtil {
  static Future<String> encrypt(String payload) async {
    final publicKeyPem = dotenv.env['JWE_RSA_PUBLIC'];
    if (publicKeyPem == null || publicKeyPem.isEmpty) {
      throw Exception('JWE_RSA_PUBLIC is not defined in the environment.');
    }

    final jwk = JsonWebKey.fromPem(publicKeyPem.replaceAll('\\n', '\n'));

    final builder = JsonWebEncryptionBuilder()
      ..stringContent = payload
      ..addRecipient(jwk, algorithm: 'RSA-OAEP-256')
      ..encryptionAlgorithm = 'A256GCM';

    final jwe = builder.build();
    return jwe.toCompactSerialization();
  }

  static Future<String> decrypt(String jweCompact) async {
    final privateKeyPem = dotenv.env['JWE_RSA_PRIVATE'];
    if (privateKeyPem == null || privateKeyPem.isEmpty) {
      throw Exception('JWE_RSA_PRIVATE is not defined in the environment.');
    }

    final jwkMap = JsonWebKey.fromPem(privateKeyPem.replaceAll('\\n', '\n')).toJson();
    
    Uint8List decodeBase64Url(String s) {
      var str = s.replaceAll('-', '+').replaceAll('_', '/');
      switch (str.length % 4) {
        case 2: str += '=='; break;
        case 3: str += '='; break;
      }
      return base64.decode(str);
    }

    BigInt decodeBigInt(List<int> bytes) {
      var result = BigInt.zero;
      for (int i = 0; i < bytes.length; i++) {
        result = (result << 8) | BigInt.from(bytes[i]);
      }
      return result;
    }

    Uint8List encodeBigInt(BigInt number) {
      int needsPaddingByte = 0;
      int numBytes = (number.bitLength + 7) >> 3;
      var result = Uint8List(numBytes + needsPaddingByte);
      for (int i = 0; i < numBytes; i++) {
        result[numBytes - 1 - i + needsPaddingByte] =
            (number >> (i * 8)).toUnsigned(8).toInt();
      }
      return result;
    }

    Uint8List mgf1(Uint8List seed, int seedOff, int seedLen, int length) {
      var mask = Uint8List(length);
      var hashBuf = Uint8List(32);
      var C = Uint8List(4);
      var counter = 0;
      var hash = SHA256Digest();

      while (counter < (length / hashBuf.length).floor()) {
        C[0] = counter >> 24; C[1] = counter >> 16; C[2] = counter >> 8; C[3] = counter;
        hash.reset();
        hash.update(seed, seedOff, seedLen);
        hash.update(C, 0, 4);
        hash.doFinal(hashBuf, 0);
        mask.setRange(counter * 32, (counter + 1) * 32, hashBuf);
        counter++;
      }

      if ((counter * 32) < length) {
        C[0] = counter >> 24; C[1] = counter >> 16; C[2] = counter >> 8; C[3] = counter;
        hash.reset();
        hash.update(seed, seedOff, seedLen);
        hash.update(C, 0, 4);
        hash.doFinal(hashBuf, 0);
        mask.setRange(counter * 32, length, hashBuf.sublist(0, length - counter * 32));
      }
      return mask;
    }

    final n = decodeBigInt(decodeBase64Url(jwkMap['n'] as String));
    final d = decodeBigInt(decodeBase64Url(jwkMap['d'] as String));

    final parts = jweCompact.split('.');
    if (parts.length != 5) {
      throw Exception('Invalid JWE compact serialization');
    }

    final b64Header = parts[0];
    final b64EncryptedKey = parts[1];
    final b64Iv = parts[2];
    final b64Ciphertext = parts[3];
    final b64Tag = parts[4];

    final encryptedKey = decodeBase64Url(b64EncryptedKey);
    final cInt = decodeBigInt(encryptedKey);
    final mInt = cInt.modPow(d, n);
    final rawPt = encodeBigInt(mInt);

    if (rawPt.length != 255) {
      throw Exception('Decryption failed: unexpected OAEP block length (\${rawPt.length})');
    }

    final maskedSeed = rawPt.sublist(0, 32);
    final maskedDB = rawPt.sublist(32);

    final seedMask = mgf1(maskedDB, 0, maskedDB.length, 32);
    final seed = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      seed[i] = maskedSeed[i] ^ seedMask[i];
    }

    final dbMask = mgf1(seed, 0, 32, maskedDB.length);
    final db = Uint8List(maskedDB.length);
    for (int i = 0; i < maskedDB.length; i++) {
      db[i] = maskedDB[i] ^ dbMask[i];
    }

    var hash = SHA256Digest();
    final pHash = Uint8List(32);
    hash.doFinal(pHash, 0);

    for (int i = 0; i < 32; i++) {
      if (db[i] != pHash[i]) {
        throw Exception('OAEP decoding error');
      }
    }

    int mStart = 32;
    while (mStart < db.length && db[mStart] == 0) {
      mStart++;
    }
    if (mStart >= db.length || db[mStart] != 1) {
      throw Exception('OAEP decoding error: failed to find 0x01 in DB');
    }
    mStart++;
    
    final cek = db.sublist(mStart);

    final aad = utf8.encode(b64Header);
    final iv = decodeBase64Url(b64Iv);
    final ciphertext = decodeBase64Url(b64Ciphertext);
    final tag = decodeBase64Url(b64Tag);

    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(false, AEADParameters(KeyParameter(cek), 128, iv, aad));

    final input = Uint8List(ciphertext.length + tag.length);
    input.setRange(0, ciphertext.length, ciphertext);
    input.setRange(ciphertext.length, input.length, tag);

    final plaintext = cipher.process(input);
    return utf8.decode(plaintext);
  }
}
