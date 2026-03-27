import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../filter_preferences_storage.dart';
import '../user_preferences_storage.dart';

final filterPreferencesStorageProvider = Provider<FilterPreferencesStorage>((ref) {
  return FilterPreferencesStorage.instance;
});

final userPreferencesStorageProvider = Provider<UserPreferencesStorage>((ref) {
  return UserPreferencesStorage.instance;
});
