import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_manager.dart';

final apiManagerProvider = Provider<ApiManager>((ref) {
  return ApiManager();
});
