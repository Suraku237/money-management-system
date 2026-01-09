import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/login_signup.dart'; // Ensure the path matches your folder structure

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set the status bar to transparent to match your radial gradient design
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Management System',
      debugShowCheckedModeBanner: false,
      
      // Defining a Global Theme that matches your app's style
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF005A6E),
        scaffoldBackgroundColor: const Color(0xFF0F171A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Or your preferred font
      ),
      
      // Starting point of the application
      home: const LoginSignupScreen(), 
    );
  }
}