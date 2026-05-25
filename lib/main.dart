import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meals/screens/auth_screen.dart';
import 'package:meals/screens/tabs.dart';
import 'package:meals/services/auth_service.dart';
import 'firebase_options.dart';


final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color(0xFF833900),
    primary: const Color(0xFFE87B3A),
    secondary: const Color(0xFFFFB347),
    surface: const Color(0xFF1A1008),
    surfaceContainerHighest: const Color(0xFF2C1A0A),
  ),
  textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
  cardTheme: CardThemeData(
    color: const Color(0xFF241509),
    elevation: 4,
    shadowColor: const Color(0xFF833900).withValues(alpha: 0.4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2C1A0A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF833900)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: const Color(0xFF833900).withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE87B3A), width: 2),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE87B3A),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF2C1A0A),
    selectedColor: const Color(0xFFE87B3A),
    labelStyle: GoogleFonts.lato(fontSize: 12),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: StreamBuilder(
        stream: AuthService().userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) return const TabsScreen();
          return const AuthScreen();
        },
      ),
    );
  }
}
