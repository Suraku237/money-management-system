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
    final String phone = _phoneController.text.trim();
    final String pin = _pinController.text.trim();

    // 1. Basic Validation
    if (amount == null || amount <= 0) {
      _showSnackBar("Please enter a valid amount", Colors.orange);
      return;
    }

    if (amount > widget.currentBalance) {
      _showSnackBar("Insufficient balance", Colors.redAccent);
      return;
    }

    if (phone.isEmpty || pin.isEmpty) {
      _showSnackBar("Phone and PIN are required", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. DATABASE ACTION
      // For withdrawals, the Helper will verify if providedPhone and providedPin 
      // match the ones saved during Signup.
      await DatabaseHelper.instance.updateBalance(
        userId: widget.userId,
        amount: amount,
        type: 'withdraw',
        providedPhone: phone,
        providedPin: pin,
      );

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar("Withdrawal of $amount FCFA successful!", Colors.green);
        Navigator.pop(context); // Go back to Home
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // This will catch "Incorrect PIN" or "Phone mismatch" from your DatabaseHelper
      _showSnackBar(e.toString().replaceAll("Exception:", ""), Colors.redAccent);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 3)),
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
                    padding: const EdgeInsets.all(24),
                    child: _buildGlassContainer(
                      child: Column(
                        children: [
                          const Icon(Icons.outbox_rounded, size: 60, color: Colors.orangeAccent),
                          const SizedBox(height: 15),
                          const Text("Withdraw Funds", 
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 10),
                          Text("Current Balance: ${widget.currentBalance.toStringAsFixed(0)} FCFA", 
                            style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          const Text("Verify your registered Phone and PIN to withdraw", 
                            style: TextStyle(color: Colors.white54, fontSize: 13), textAlign: TextAlign.center),
                          const SizedBox(height: 30),
                          
                          _buildInput(_phoneController, "Registered Phone Number", Icons.phone_android, isNum: true),
                          const SizedBox(height: 20),
                          _buildInput(_amountController, "Amount to Withdraw (FCFA)", Icons.money_off_rounded, isNum: true),
                          const SizedBox(height: 20),
                          _buildInput(_pinController, "Security PIN", Icons.lock_person_rounded, isObscure: true, isNum: true),
                          
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

  // --- UI COMPONENTS ---

  Widget _buildBackground() => Container(
    decoration: const BoxDecoration(
      gradient: RadialGradient(center: Alignment.center, radius: 1.5, colors: [Color(0xFF1B3B44), Color(0xFF0F171A)])
    )
  );

  Widget _buildAppBar(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
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
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05), 
          borderRadius: BorderRadius.circular(30), 
          border: Border.all(color: Colors.white.withOpacity(0.1))
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
      prefixIcon: Icon(icon, color: Colors.orangeAccent, size: 20),
      filled: true,
      fillColor: Colors.black26,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.orangeAccent)),
    ),
  );

  Widget _buildButton(String text, VoidCallback onPressed) => SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade800, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
      ),
      child: _isLoading 
        ? const CircularProgressIndicator(color: Colors.white) 
        : Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
}