import 'package:flutter/material.dart';
import 'dart:ui';
import 'database_helper.dart';

class WithdrawPage extends StatefulWidget {
  final double currentBalance;
  final int userId;

  const WithdrawPage({super.key, required this.currentBalance, required this.userId});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  void _handleWithdraw() async {
    final double? amount = double.tryParse(_amountController.text);

    // 1. Validation Checks
    if (amount == null || amount <= 0) {
      _showSnackBar("Please enter a valid amount", Colors.orange);
      return;
    }

    if (amount > widget.currentBalance) {
      _showSnackBar("Insufficient funds! Your balance is ${widget.currentBalance} FCFA", Colors.redAccent);
      return;
    }

    if (_pinController.text.isEmpty) {
      _showSnackBar("Please enter your PIN", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. DATABASE ACTION
      // This subtracts from 'users' table and adds a row to 'transactions' table
      await DatabaseHelper.instance.updateBalance(widget.userId, amount, 'withdraw');

      // Small delay for UX
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar("Withdrawal of $amount FCFA successful!", Colors.green);
        
        // 3. Return to Home Page (Home Page will auto-refresh via _navigateTo)
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Transaction failed. Please try again.", Colors.redAccent);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildGlassContainer(
                      child: Column(
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded, size: 60, color: Color(0xFFE2C08D)),
                          const SizedBox(height: 15),
                          const Text("Withdraw Funds", 
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 30),
                          
                          _buildInput(_phoneController, "Phone Number", Icons.phone_android, isNum: true),
                          const SizedBox(height: 20),
                          _buildInput(_amountController, "Amount (FCFA)", Icons.money_off, isNum: true),
                          const SizedBox(height: 20),
                          _buildInput(_pinController, "Mobile Money PIN", Icons.lock, isObscure: true, isNum: true),
                          
                          const SizedBox(height: 40),
                          _buildButton("CONFIRM WITHDRAWAL", _handleWithdraw),
                        ],
                      ),
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

  // --- UI COMPONENTS (Match your design) ---

  Widget _buildBackground() => Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment.center, radius: 1.5, colors: [Color(0xFF1B3B44), Color(0xFF0F171A)])));

  Widget _buildAppBar(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        const Text("Withdraw", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    ),
  );

  Widget _buildGlassContainer({required Widget child}) => ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.1))),
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
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.cyan),
      filled: true,
      fillColor: Colors.black26,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.cyan)),
    ),
  );

  Widget _buildButton(String text, VoidCallback onPressed) => SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005A6E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
}