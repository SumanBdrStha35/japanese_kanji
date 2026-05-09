import 'package:flutter/material.dart';
import 'package:jap_n5_learn/screens/main_navigation_screen.dart';
import 'package:provider/provider.dart';
import 'package:jap_n5_learn/config/theme.dart';
import 'package:jap_n5_learn/config/constants.dart';
import 'package:jap_n5_learn/providers/theme_provider.dart';
import 'package:jap_n5_learn/providers/kanji_provider.dart';
import 'package:jap_n5_learn/providers/gamification_provider.dart';
import 'package:jap_n5_learn/providers/quiz_provider.dart';
import 'package:jap_n5_learn/providers/settings_provider.dart';
import 'package:jap_n5_learn/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme before building the widget tree to avoid a theme "flash".
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => KanjiProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          // home: const SplashScreen(), 
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}