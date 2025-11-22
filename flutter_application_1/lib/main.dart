import 'package:flutter/material.dart';
import 'pages/home_page.dart'; // Import your HomePage file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Wallet App",
      theme: ThemeData(
        primaryColor: const Color(0xFF39A9A9),
      ),

      // Provide an initial balance to HomePage
      home: const HomePage(
        currentBalance: 50000,   // Set any starting balance you want
      ),
    );
  }
}
