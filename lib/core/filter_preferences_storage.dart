import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/filter_preferences_entity.dart';

class FilterPreferencesStorage {
  FilterPreferencesStorage._(this._preferences);

  static const String _filterPreferencesKey = 'filter_preferences';
  static FilterPreferencesStorage? _instance;

  final SharedPreferences _preferences;

  static FilterPreferencesStorage get instance {
    final storage = _instance;
    if (storage == null) {
      throw StateError('FilterPreferencesStorage has not been initialized.');
    }
    return storage;
  }

  static Future<void> init() async {
    if (_instance != null) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    _instance = FilterPreferencesStorage._(preferences);
  }

  FilterPreferencesEntity? getFilterPreferences() {
    final raw = _preferences.getString(_filterPreferencesKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) {
        return null;
      }
      return FilterPreferencesEntity.fromJson(json);
    } on FormatException {
      return null;
    }
  }

  Future<void> saveFilterPreferences(FilterPreferencesEntity filters) async {
    final payload = jsonEncode(filters.toJson());
    await _preferences.setString(_filterPreferencesKey, payload);
  }

  Future<void> clearFilterPreferences() async {
    await _preferences.remove(_filterPreferencesKey);
  }
}
