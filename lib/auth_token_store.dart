import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

@immutable
class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  static AuthTokens? validated({
    required String? accessToken,
    required String? refreshToken,
  }) {
    final normalizedAccessToken = accessToken?.trim() ?? '';
    final normalizedRefreshToken = refreshToken?.trim() ?? '';

    if (normalizedAccessToken.isEmpty || normalizedRefreshToken.isEmpty) {
      return null;
    }

    return AuthTokens(
      accessToken: normalizedAccessToken,
      refreshToken: normalizedRefreshToken,
    );
  }
}

class AuthTokenStore extends ValueNotifier<AuthTokens?> {
  AuthTokenStore({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
      super(null);

  static const _secureKeyName = 'auth_box_encryption_key';
  static const _boxName = 'auth_tokens';
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _secureStorage;
  Box<dynamic>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    final key = await _readOrCreateEncryptionKey();
    try {
      _box = await Hive.openBox<dynamic>(
        _boxName,
        encryptionCipher: HiveAesCipher(key),
      );
    } catch (_) {
      // Box is corrupted or key mismatch — delete stored key and box, then
      // reinitialise with a fresh key so the store fails closed (empty) rather
      // than preventing app startup.
      await _secureStorage.delete(key: _secureKeyName);
      await Hive.deleteBoxFromDisk(_boxName);
      final freshKey = await _readOrCreateEncryptionKey();
      _box = await Hive.openBox<dynamic>(
        _boxName,
        encryptionCipher: HiveAesCipher(freshKey),
      );
    }
    value = _readTokensFromBox();
  }

  Future<bool> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final tokens = AuthTokens.validated(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    if (tokens == null) {
      await clear();
      return false;
    }

    final box = _requireBox();
    await box.put(_accessTokenKey, tokens.accessToken);
    await box.put(_refreshTokenKey, tokens.refreshToken);
    value = tokens;
    return true;
  }

  Future<AuthTokens?> reload() async {
    value = _readTokensFromBox();
    return value;
  }

  Future<void> clear() async {
    final box = _requireBox();
    await box.delete(_accessTokenKey);
    await box.delete(_refreshTokenKey);
    value = null;
  }

  Future<Uint8List> _readOrCreateEncryptionKey() async {
    final encodedKey = await _secureStorage.read(key: _secureKeyName);
    if (encodedKey != null && encodedKey.isNotEmpty) {
      return base64.decode(encodedKey);
    }

    final key = Hive.generateSecureKey();
    await _secureStorage.write(key: _secureKeyName, value: base64.encode(key));
    return Uint8List.fromList(key);
  }

  AuthTokens? _readTokensFromBox() {
    final box = _requireBox();
    final tokens = AuthTokens.validated(
      accessToken: box.get(_accessTokenKey) as String?,
      refreshToken: box.get(_refreshTokenKey) as String?,
    );

    if (tokens == null) {
      box.delete(_accessTokenKey);
      box.delete(_refreshTokenKey);
    }

    return tokens;
  }

  Box<dynamic> _requireBox() {
    final box = _box;
    if (box == null) {
      throw StateError('AuthTokenStore.init must complete before use.');
    }
    return box;
  }
}
