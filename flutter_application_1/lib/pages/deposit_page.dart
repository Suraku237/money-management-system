import 'package:flutter/material.dart';
import 'dart:ui';
import 'database_helper.dart';

class DepositPage extends StatefulWidget {
  final double currentBalance;
  final int userId;

  const DepositPage({super.key, required this.currentBalance, required this.userId});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  void _handleDeposit() async {
    final double? amount = double.tryParse(_amountController.text);
    final String phone = _phoneController.text.trim();
    final String pin = _pinController.text.trim();

    if (amount == null || amount <= 0) {
      _showSnackBar("Please enter a valid amount", Colors.orange);
      return;
    }

    if (phone.isEmpty || pin.isEmpty) {
      _showSnackBar("Please fill in all fields", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Passes parameters to DatabaseHelper
      await DatabaseHelper.instance.updateBalance(
        userId: widget.userId,
        amount: amount,
        type: 'deposit',
        providedPhone: phone,
        providedPin: pin,
      );

      // Brief delay for better UX feel
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessDialog(amount);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Deposit failed: ${e.toString()}", Colors.redAccent);
    }
  }

  // A nice success popup before returning to Home
  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B3B44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 60),
        content: Text(
          "Successfully deposited ${amount.toStringAsFixed(0)} FCFA into your account.",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to Home
            },
            child: const Text("CONTINUE", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F171A),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Column(
                      children: [
                        _buildGlassContainer(
                          child: Column(
                            children: [
                              const Icon(Icons.account_balance_wallet_rounded, size: 50, color: Colors.cyan),
                              const SizedBox(height: 15),
                              const Text("Deposit Money", 
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                              const Text("Refill your wallet via Mobile Money", 
                                style: TextStyle(color: Colors.white54, fontSize: 13)),
                              const SizedBox(height: 30),

                              _buildInput(_phoneController, "Sender Phone Number", Icons.phone_android, isNum: true),
                              const SizedBox(height: 20),
                              _buildInput(_amountController, "Amount (FCFA)", Icons.add_chart_rounded, isNum: true),
                              const SizedBox(height: 20),
                              _buildInput(_pinController, "Momo PIN", Icons.lock_outline, isObscure: true, isNum: true),
                              
                              const SizedBox(height: 40),
                              _buildButton("CONFIRM DEPOSIT", _handleDeposit),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() => Container(
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.center, 
        radius: 1.5, 
        colors: [Color(0xFF1B3B44), Color(0xFF0F171A)]
      )
    )
  );

  Widget _buildAppBar(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), 
          onPressed: () => Navigator.pop(context)
        ),
        const Text("Deposit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    ),
  );

  Widget _buildGlassContainer({required Widget child}) => ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03), 
          borderRadius: BorderRadius.circular(30), 
          border: Border.all(color: Colors.white.withOpacity(0.05))
        ),
        child: child,
      ),
    ),
  );

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {bool isObscure = false, bool isNum = false}) => TextField(
    controller: controller,
    obscureText: isObscure,
    keyboardType: isNum ? TextInputType.number : TextInputType.text,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.cyan, size: 20),
      filled: true,
      fillColor: Colors.black26,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15), 
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1))
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15), 
        borderSide: const BorderSide(color: Colors.cyan)
      ),
    ),
  );

  Widget _buildButton(String text, VoidCallback onPressed) => SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
      child: _isLoading 
        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) 
        : Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
    ),
  );
}