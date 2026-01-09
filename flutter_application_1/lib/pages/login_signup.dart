import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'home_page.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // --- LOGIC: SIGN UP ---
  void _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 1. Basic Validation
    if (name.isEmpty || email.isEmpty || phone.isEmpty || pin.isEmpty || password.isEmpty) {
      _showMessage("Please fill all fields", Colors.orange);
      return;
    }
    if (password != confirmPassword) {
      _showMessage("Passwords do not match!", Colors.redAccent);
      return;
    }
    if (pin.length < 4) {
      _showMessage("PIN must be at least 4 digits", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Database Insert
      await DatabaseHelper.instance.insertUser({
        'username': name,
        'email': email,
        'phone': phone,
        'pin': pin,
        'password': password,
        'balance': 0.0,
      });

      setState(() {
        _isLoading = false;
        isLogin = true; // Switch to login view after success
      });
      _showMessage("Account created! Please login.", Colors.green);
      
      // Clear controllers for login
      _passwordController.clear();
      _confirmPasswordController.clear();

    } catch (e) {
      setState(() => _isLoading = false);
      
      // 3. Specific Error Handling for Unique Constraints
      String errorMsg = "Registration failed";
      if (e.toString().contains("users.phone")) {
        errorMsg = "This phone number is already registered!";
      } else if (e.toString().contains("users.email")) {
        errorMsg = "This email is already in use!";
      }
      
      _showMessage(errorMsg, Colors.redAccent);
    }
  }

  // --- LOGIC: LOGIN ---
  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please fill all fields", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    final user = await DatabaseHelper.instance.checkUser(email, password);
    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(user: user)),
      );
    } else {
      _showMessage("Invalid email or password.", Colors.redAccent);
    }
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F171A),
      body: Container(
        // Added gradient to match other screens
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1B3B44), Color(0xFF0F171A)]
          )
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const Icon(Icons.account_balance_wallet, size: 70, color: Colors.cyan),
                  const SizedBox(height: 20),
                  Text(
                    isLogin ? "Welcome Back" : "Get Started",
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLogin ? "Securely manage your funds" : "Create a secure wallet account",
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 40),

                  // Form Fields
                  if (!isLogin) ...[
                    _buildTextField(_nameController, "User Name", Icons.person_outline),
                    const SizedBox(height: 15),
                    _buildTextField(_phoneController, "Phone Number", Icons.phone_android_outlined, isNum: true),
                    const SizedBox(height: 15),
                    _buildTextField(_pinController, "4-Digit Withdrawal PIN", Icons.pin_outlined, isNum: true, isObscure: true),
                    const SizedBox(height: 15),
                  ],

                  _buildTextField(_emailController, "Email Address", Icons.email_outlined),
                  const SizedBox(height: 15),
                  
                  _buildTextField(
                    _passwordController, 
                    "Password", 
                    Icons.lock_outline, 
                    isObscure: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.cyan, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),

                  if (!isLogin) ...[
                    const SizedBox(height: 15),
                    _buildTextField(_confirmPasswordController, "Confirm Password", Icons.lock_reset_outlined, isObscure: _obscurePassword),
                  ],

                  const SizedBox(height: 30),
                  _buildButton(),
                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        // Keep emails but clear sensitive data when switching
                        _passwordController.clear();
                        _confirmPasswordController.clear();
                        _pinController.clear();
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        text: isLogin ? "New here? " : "Already have an account? ",
                        style: const TextStyle(color: Colors.white54),
                        children: [
                          TextSpan(
                            text: isLogin ? "Sign Up" : "Login",
                            style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isObscure = false, bool isNum = false, Widget? suffixIcon}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: isNum ? TextInputType.number : (hint.contains("Email") ? TextInputType.emailAddress : TextInputType.text),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.cyan, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.black26,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.cyan, width: 1)),
      ),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        onPressed: _isLoading ? null : (isLogin ? _handleLogin : _handleSignUp),
        child: _isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) 
          : Text(
              isLogin ? "LOGIN" : "CREATE ACCOUNT", 
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
            ),
      ),
    );
  }
}