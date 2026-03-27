import 'package:dcs_supervisor/core/commons/app_colors.dart';
import 'package:dcs_supervisor/core/filter_preferences_storage.dart';
import 'package:dcs_supervisor/core/providers.dart';
import 'package:dcs_supervisor/core/user_preferences_storage.dart';
import 'package:dcs_supervisor/screens/login_screen.dart';
import 'package:dcs_supervisor/screens/survey_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await FilterPreferencesStorage.init();
  await UserPreferencesStorage.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'Supervisor Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: authState.isLoggedIn
          ? const SurveyListScreen()
          : const LoginScreen(),
    );
  }
}
