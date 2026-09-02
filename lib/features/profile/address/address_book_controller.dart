import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/saved_address.dart';

class AddressBookController extends ChangeNotifier {
  AddressBookController._();

  static final AddressBookController instance = AddressBookController._();
  static const String _storageKey = 'dcx.saved_addresses.v1';

  final List<SavedAddress> _addresses = <SavedAddress>[];
  SharedPreferencesAsync? _preferences;
  bool _loaded = false;
  Future<void>? _loadFuture;

  List<SavedAddress> get addresses => List<SavedAddress>.unmodifiable(_addresses);
  bool get isLoaded => _loaded;
  bool get hasAddresses => _addresses.isNotEmpty;

  SavedAddress? get defaultAddress {
    if (_addresses.isEmpty) return null;
    for (final address in _addresses) {
      if (address.isDefault) return address;
    }
    return _addresses.first;
  }

  Future<void> load() {
    if (_loaded) return Future<void>.value();
    return _loadFuture ??= _loadInternal();
  }

  Future<void> _loadInternal() async {
    try {
      final raw = await _store().getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _addresses
            ..clear()
            ..addAll(
              decoded
                  .whereType<Map>()
                  .map((item) => SavedAddress.fromJson(Map<String, dynamic>.from(item))),
            );
          _normalizeDefault();
          notifyListeners();
        }
      }
    } catch (_) {
      // Widget tests and unsupported hosts may not register the preferences
      // platform. The controller intentionally remains usable in memory.
    } finally {
      _loaded = true;
      _loadFuture = null;
    }
  }

  Future<void> save(SavedAddress address, {bool persist = true}) async {
    final index = _addresses.indexWhere((item) => item.id == address.id);
    final shouldDefault = address.isDefault || _addresses.isEmpty;
    final normalized = address.copyWith(isDefault: shouldDefault);

    if (shouldDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }

    if (index == -1) {
      _addresses.add(normalized);
    } else {
      _addresses[index] = normalized;
    }

    _normalizeDefault();
    notifyListeners();
    if (persist) await _persistSafely();
  }

  Future<void> remove(String id, {bool persist = true}) async {
    _addresses.removeWhere((item) => item.id == id);
    _normalizeDefault();
    notifyListeners();
    if (persist) await _persistSafely();
  }

  Future<void> setDefault(String id, {bool persist = true}) async {
    var changed = false;
    for (var i = 0; i < _addresses.length; i++) {
      final next = _addresses[i].copyWith(isDefault: _addresses[i].id == id);
      if (next.isDefault != _addresses[i].isDefault) changed = true;
      _addresses[i] = next;
    }
    if (!changed) return;
    notifyListeners();
    if (persist) await _persistSafely();
  }

  void resetForTesting({List<SavedAddress> addresses = const <SavedAddress>[]}) {
    _addresses
      ..clear()
      ..addAll(addresses);
    _loaded = true;
    _loadFuture = null;
    _normalizeDefault();
    notifyListeners();
  }

  SharedPreferencesAsync _store() => _preferences ??= SharedPreferencesAsync();

  Future<void> _persistSafely() async {
    try {
      final payload = jsonEncode(_addresses.map((item) => item.toJson()).toList());
      await _store().setString(_storageKey, payload);
    } catch (_) {
      // Keep the in-memory experience working if persistence is unavailable.
    }
  }

  void _normalizeDefault() {
    if (_addresses.isEmpty) return;
    final defaults = _addresses.where((item) => item.isDefault).toList();
    if (defaults.length == 1) return;

    final defaultId = defaults.isEmpty ? _addresses.first.id : defaults.first.id;
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == defaultId);
    }
  }
}
