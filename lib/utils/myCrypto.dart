import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
// import 'package:encrypt/encrypt.dart';
// import 'package:crypto/crypto.dart'; // key 생성을 위해 사용

class MyCrypto {
  MyCrypto._privateConstructor();
  static final MyCrypto _instance = MyCrypto._privateConstructor();

  factory MyCrypto() {
    return _instance;
  }

  // // AES 키 및 IV 생성 함수
  // static Key generateKey(String meetId, String keySalt) {
  //   final keyBytes = sha256.convert(utf8.encode(meetId + keySalt)).bytes;
  //   return Key(Uint8List.fromList(keyBytes.sublist(0, 32)));
  // }

  // static IV generateIV(String ivSeed, String ivSalt) {
  //   // ivSeed와 ivSalt를 결합하여 16바이트로 변환
  //   final combined = ivSeed + ivSalt;
  //   final ivBytes = utf8.encode(combined.padRight(16, '0')).sublist(0, 16);
  //   return IV(Uint8List.fromList(ivBytes));
  // }

  // // 암호화 함수
  // static Uint8List encryptData(Uint8List data, Key key, IV iv) {
  //   final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  //   final encrypted = encrypter.encryptBytes(data, iv: iv);
  //   return encrypted.bytes;
  // }

  // // 복호화 함수
  // static Uint8List decryptData(Uint8List encryptedData, Key key, IV iv) {
  //   final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  //   final decrypted = encrypter.decryptBytes(Encrypted(encryptedData), iv: iv);
  //   return Uint8List.fromList(decrypted);
  // }

  static final List<int> validKeySizes = [128, 192, 256];
  static const int validIvSize = 128; // IV is always 128 bits

  // AES Key Generation
  static Future<Uint8List> generateAESKey(
      String password, String salt, int keySize) async {
    assert(password.isNotEmpty, "Password cannot be empty");
    assert(salt.isNotEmpty && utf8.encode(salt).length >= 8,
        "Salt must be at least 8 bytes");
    assert(validKeySizes.contains(keySize), "Invalid key size");

    // Use PBKDF2 with HMAC-SHA1 to generate the key
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac(Sha1()), // C# uses HMAC-SHA1
      iterations: 10000, // Same as Rfc2898DeriveBytes
      bits: keySize, // Key size in bits
    );

    // Convert password and salt to Uint8List
    final passwordBytes = utf8.encode(password);
    final saltBytes = utf8.encode(salt);

    // Derive key
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(passwordBytes),
      nonce: saltBytes,
    );

    return Uint8List.fromList(await secretKey.extractBytes());
  }

  // AES IV Generation
  static Future<Uint8List> generateAESIV(String password, String salt) async {
    return generateAESKey(password, salt, validIvSize); // IV is always 128 bits
  }

  // AES Encryption
  static Future<Uint8List> encryptData(
      Uint8List data, Uint8List key, Uint8List iv) async {
    final algorithm = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);

    final secretKey = SecretKey(key);

    final result = await algorithm.encrypt(
      data,
      secretKey: secretKey,
      nonce: iv, // IV is the nonce in cryptography
    );

    return Uint8List.fromList(result.cipherText);
  }

  // AES Decryption
  static Future<Uint8List> decryptData(
      Uint8List encryptedData, Uint8List key, Uint8List iv) async {
    final algorithm = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);

    final secretKey = SecretKey(key);

    final result = await algorithm.decrypt(
      SecretBox(encryptedData, nonce: iv, mac: Mac.empty),
      secretKey: secretKey,
    );

    return Uint8List.fromList(result);
  }
}
