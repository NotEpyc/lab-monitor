import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lab_monitor/theme/theme.dart';
import 'package:lab_monitor/screens/login/dummy_signin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style for light theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.light, // For iOS (dark icons)
    ),
  );
  runApp(const LabMonitor());
}

class LabMonitor extends StatelessWidget {
  const LabMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        // Update status bar based on current theme brightness
        final brightness = MediaQuery.platformBrightnessOf(context);
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: brightness == Brightness.dark 
                ? Brightness.light 
                : Brightness.dark,
          )
        );
        
        // Apply a maximum width constraint to the entire app
        return MediaQuery(
          // Preserve original media query data but apply our constraints
          data: MediaQuery.of(context).copyWith(
            // Optional: adjust text scaling to ensure consistent text size
            textScaleFactor: 1.0,
          ),
          child: child!,
        );
      },
      home: DummySignInPage(),
    );
  }
}