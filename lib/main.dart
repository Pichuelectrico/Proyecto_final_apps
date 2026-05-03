import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants.dart';
import 'presentacion/providers/auth_provider.dart';
import 'presentacion/vistas/home_shell.dart';
import 'presentacion/vistas/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: VibeShareApp()));
}

class VibeShareApp extends ConsumerWidget {
  const VibeShareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: kBackgroundGrey,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryBlue,
        primary: kPrimaryBlue,
        secondary: kSecondaryGreen,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCornerRadiusLg),
        ),
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kCornerRadiusMd),
          borderSide: BorderSide.none,
        ),
      ),
    );

    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: ref.watch(authStateProvider).when(
            data: (user) => user == null ? const LoginPage() : const HomeShell(),
            error: (error, _) => Scaffold(body: Center(child: Text('$error'))),
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          ),
    );
  }
}
