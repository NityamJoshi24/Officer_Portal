import '../models/filter_preferences_entity.dart';
import '../objectbox.g.dart';

class ObjectBox {
  ObjectBox._(this.store)
    : _filterPreferencesBox = store.box<FilterPreferencesEntity>();

  static ObjectBox? _instance;

  final Store store;
  final Box<FilterPreferencesEntity> _filterPreferencesBox;

  static ObjectBox get instance {
    final objectBox = _instance;
    if (objectBox == null) {
      throw StateError('ObjectBox has not been initialized.');
    }
    return objectBox;
  }

  static Future<void> init() async {
    if (_instance != null) {
      return;
    }

    final store = await openStore();
    _instance = ObjectBox._(store);
  }

  FilterPreferencesEntity? getFilterPreferences() {
    final all = _filterPreferencesBox.getAll();
    if (all.isEmpty) {
      return null;
    }
    return all.first;
  }

  void saveFilterPreferences(FilterPreferencesEntity filters) {
    final existing = getFilterPreferences();
    filters.id = existing?.id ?? 0;
    _filterPreferencesBox.put(filters);
  }

  void clearFilterPreferences() {
    final existing = getFilterPreferences();
    if (existing != null) {
      _filterPreferencesBox.remove(existing.id);
    }
  }
}
