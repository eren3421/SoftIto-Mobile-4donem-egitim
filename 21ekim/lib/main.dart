import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'state/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/greenhouse_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const BahcivanApp(),
    ),
  );
}

class BahcivanApp extends StatelessWidget {
  const BahcivanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return MaterialApp(
      title: 'BAHÇIVAN — Sera ve Bitki Yönetimi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7F4),
        fontFamily: GoogleFonts.inter().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF1B5E20),
          secondary: const Color(0xFF4CAF50),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: state.isLoading
          ? const Scaffold(
              backgroundColor: Color(0xFFF4F7F4),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🌿', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 16),
                    CircularProgressIndicator(
                      color: Color(0xFF1B5E20),
                    ),
                  ],
                ),
              ),
            )
          : (state.isLoggedIn
              ? const GreenhouseListScreen()
              : const AuthScreen()),
    );
  }
}
