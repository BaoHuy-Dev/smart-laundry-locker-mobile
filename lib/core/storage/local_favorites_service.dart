import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/locker.dart';
import '../models/store.dart';

class LocalFavoritesService {
  LocalFavoritesService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _favoriteStoresKey = 'favorite_stores';
  static const _favoriteLockersKey = 'favorite_lockers';

  static Future<Map<int, Store>> getFavoriteStores() async {
    final raw = await _storage.read(key: _favoriteStoresKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        int.parse(key),
        Store.fromJson(Map<String, dynamic>.from(value as Map)),
      ),
    );
  }

  static Future<Map<int, Locker>> getFavoriteLockers() async {
    final raw = await _storage.read(key: _favoriteLockersKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        int.parse(key),
        Locker.fromJson(Map<String, dynamic>.from(value as Map)),
      ),
    );
  }

  static Future<Map<int, Store>> toggleStore(Store store) async {
    final favorites = await getFavoriteStores();
    if (favorites.containsKey(store.id)) {
      favorites.remove(store.id);
    } else {
      favorites[store.id] = store;
    }
    await _writeStores(favorites);
    return favorites;
  }

  static Future<Map<int, Locker>> toggleLocker(Locker locker) async {
    final favorites = await getFavoriteLockers();
    if (favorites.containsKey(locker.id)) {
      favorites.remove(locker.id);
    } else {
      favorites[locker.id] = locker;
    }
    await _writeLockers(favorites);
    return favorites;
  }

  static Future<void> _writeStores(Map<int, Store> favorites) async {
    final encoded = favorites.map(
      (key, value) => MapEntry(key.toString(), value.toJson()),
    );
    await _storage.write(key: _favoriteStoresKey, value: jsonEncode(encoded));
  }

  static Future<void> _writeLockers(Map<int, Locker> favorites) async {
    final encoded = favorites.map(
      (key, value) => MapEntry(key.toString(), value.toJson()),
    );
    await _storage.write(key: _favoriteLockersKey, value: jsonEncode(encoded));
  }
}
