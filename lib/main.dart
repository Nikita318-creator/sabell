import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_sabel/l10n/app_localizations.dart'; // Импорт локализации

import 'features/onbording/presentetion/main_tab_screen.dart';
import 'features/onbording/presentetion/onbording_screen.dart';
import 'package:flutter_sabel/core/di/injection_container.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isOnboardingCompleted = prefs.getBool('isOnboardingCompleted') ?? false;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDependencies();

  runApp(MyApp(isOnboardingCompleted: isOnboardingCompleted));
}

class MyApp extends StatelessWidget {
  final bool isOnboardingCompleted;

  const MyApp({super.key, required this.isOnboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: isOnboardingCompleted
          ? const MainTabScreen()
          : const OnboardingScreen(),
    );
  }
}
