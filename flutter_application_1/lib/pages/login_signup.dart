import 'package:flutter/material.dart';
import 'dart:ui';
import 'home_page.dart';
// IMPORT your database helper here
// import '../database/database_helper.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(); // Changed to Email
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Please enter email and password");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. DATABASE SEARCH (Uncomment when you add the DatabaseHelper file)
      // final user = await DatabaseHelper.instance.getUser(_emailController.text);
      
      // FOR DEMO: Creating a mock user that looks like a database result
      final Map<String, dynamic> mockUser = {
        'id': 1,
        'username': 'User',
        'email': _emailController.text,
        'balance': 1000.0,
      };

      await Future.delayed(const Duration(milliseconds: 800)); // Simulate delay

      if (mounted) {
        setState(() => _isLoading = false);
        
        // 2. PASS THE USER TO HOME PAGE
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(user: mockUser)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Login failed. Check your credentials.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
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
                    const Text("Money Manager", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Text("Secure Access", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 40),
                    
                    _buildInput(_emailController, "Email Address", Icons.email_outlined),
                    const SizedBox(height: 20),
                    _buildInput(_passwordController, "Password", Icons.lock_outline, isObscure: true),
                    
                    const SizedBox(height: 40),
                    _buildButton("LOG IN", _login),
                    const SizedBox(height: 30),
                    
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                      child: const Text("Don't have an account? Sign Up", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
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

  // UI Helper methods (Background, GlassContainer, etc.) remain as per your design
  Widget _buildBackground() => Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment.center, radius: 1.5, colors: [Color(0xFF1B3B44), Color(0xFF0F171A)])));
  
  Widget _buildGlassContainer({required Widget child}) => ClipRRect(borderRadius: BorderRadius.circular(30), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.1))), child: child)));

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {bool isObscure = false}) => TextField(
    controller: controller, obscureText: isObscure, style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white54), prefixIcon: Icon(icon, color: Colors.cyan), filled: true, fillColor: Colors.black26, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.cyan)))
  );

  Widget _buildButton(String text, VoidCallback onPressed) => SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _isLoading ? null : onPressed, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005A6E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), side: const BorderSide(color: Color(0xFFE2C08D))), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))));
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // DATABASE INSERTION LOGIC:
        // await DatabaseHelper.instance.insertUser({
        //   'username': _nameController.text,
        //   'email': _emailController.text,
        //   'password': _passwordController.text,
        //   'balance': 0.0
        // });

        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created! Please Login."), backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email already exists!"), backgroundColor: Colors.redAccent));
      }
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
                      const Text("CREATE ACCOUNT", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 30),
                      _buildRegInput(_nameController, "Full Name", Icons.person, (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 15),
                      _buildRegInput(_emailController, "Email", Icons.email, (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 15),
                      _buildRegInput(_passwordController, "Password", Icons.lock, (v) => v!.length < 6 ? 'Min 6 chars' : null, isObscure: true),
                      const SizedBox(height: 30),
                      _buildButton("SIGN UP", _submitForm),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text("Back to Login", style: TextStyle(color: Colors.white70)),
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

  // Reusing the same UI builders from Login for consistency...
  Widget _buildBackground() => Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment.center, radius: 1.5, colors: [Color(0xFF1B3B44), Color(0xFF0F171A)])));
  Widget _buildGlassContainer({required Widget child}) => ClipRRect(borderRadius: BorderRadius.circular(30), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.1))), child: child)));
  Widget _buildRegInput(TextEditingController controller, String hint, IconData icon, String? Function(String?)? validator, {bool isObscure = false}) => TextFormField(controller: controller, obscureText: isObscure, validator: validator, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white54), prefixIcon: Icon(icon, color: Colors.cyan), filled: true, fillColor: Colors.black26, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.cyan))));
  Widget _buildButton(String text, VoidCallback onPressed) => SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : onPressed, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005A6E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))));
}