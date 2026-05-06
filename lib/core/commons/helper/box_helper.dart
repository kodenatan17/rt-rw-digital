import 'package:hive_flutter/hive_flutter.dart';
import 'package:pasconnect/features/services/datasources/secure_storage.dart';

class BoxHelper {
  Future<Box> getBox(String boxName) async {
    final key = await SecureHive().getKey();
    final box = await Hive.openBox(
      boxName,
      encryptionCipher: HiveAesCipher(key),
    );
    return box;
  }
}