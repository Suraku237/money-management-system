import 'package:flutter/material.dart';
import 'dart:ui';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Management System',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.cyan,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// -------------------- LOGIN SCREEN --------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() {
    setState(() => _isLoading = true);
    
    // Simulate a short delay then go to Home Page
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage(currentBalance: 1000.0)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildGlassContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 60, color: Color(0xFFE2C08D)),
                    const SizedBox(height: 15),
                    const Text(
                      "To Manage your money",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Text("Secure & Simple Access", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 40),
                    _buildInput(_nameController, "Username", Icons.person_outline),
                    const SizedBox(height: 20),
                    _buildInput(_passwordController, "Password", Icons.lock_outline, isObscure: true),
                    const SizedBox(height: 40),
                    _buildButton("LOG IN", _login),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                      child: const Text("Don't have an account? Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() => Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment.center, radius: 1.5, colors: [Color(0xFF1B3B44), Color(0xFF0F171A)])));

  Widget _buildGlassContainer({required Widget child}) => ClipRRect(borderRadius: BorderRadius.circular(30), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.1))), child: child)));

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {bool isObscure = false}) => TextField(
    controller: controller, 
    obscureText: isObscure, 
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint, 
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.cyan), 
      filled: true, 
      fillColor: Colors.black26, 
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))), 
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.cyan))
    )
  );

  Widget _buildButton(String text, VoidCallback onPressed) => SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _isLoading ? null : onPressed, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005A6E), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), side: const BorderSide(color: Color(0xFFE2C08D))), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))));
}

// -------------------- SIGNUP SCREEN --------------------

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulate account creation
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created! (Offline Mode)"), backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildGlassContainer(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text("CREATE ACCOUNT", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white)),
                      const SizedBox(height: 30),
                      _buildRegInput(_nameController, "Username", Icons.person, (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 15),
                      _buildRegInput(_ageController, "Age", Icons.cake, (v) => v!.isEmpty ? 'Required' : null, isNum: true),
                      const SizedBox(height: 15),
                      _buildRegInput(_emailController, "Email", Icons.email, (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 15),
                      _buildRegInput(_passwordController, "Password", Icons.lock, (v) => v!.length < 6 ? 'Min 6 chars' : null, isObscure: true),
                      const SizedBox(height: 15),
                      _buildRegInput(_confirmPasswordController, "Confirm Password", Icons.lock_reset, (v) => v != _passwordController.text ? "Mismatch" : null, isObscure: true),
                      const SizedBox(height: 30),
                      _buildButton("SIGN UP", _submitForm),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text("Already have an account? Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() => Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment.center, radius: 1.5, colors: [Color(0xFF1B3B44), Color(0xFF0F171A)])));

  Widget _buildGlassContainer({required Widget child}) => ClipRRect(borderRadius: BorderRadius.circular(30), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.1))), child: child)));

  Widget _buildRegInput(TextEditingController controller, String hint, IconData icon, String? Function(String?)? validator, {bool isObscure = false, bool isNum = false}) => TextFormField(
    controller: controller, 
    obscureText: isObscure, 
    keyboardType: isNum ? TextInputType.number : TextInputType.text, 
    validator: validator, 
    style: const TextStyle(fontSize: 14, color: Colors.white), 
    decoration: InputDecoration(
      hintText: hint, 
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.cyan, size: 20), 
      filled: true, 
      fillColor: Colors.black26, 
      contentPadding: const EdgeInsets.symmetric(vertical: 15), 
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))), 
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.cyan))
    )
  );

  Widget _buildButton(String text, VoidCallback onPressed) => SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : onPressed, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005A6E), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: Color(0xFFE2C08D))), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))));
}