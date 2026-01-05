import 'package:flutter/material.dart';
import 'dart:ui';

class WithdrawPage extends StatefulWidget {
  final double currentBalance;

  const WithdrawPage({super.key, required this.currentBalance});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  String selectedCountry = "Cameroon";
  String countryCode = "+237";
  bool _isLoading = false;

  final Map<String, Map<String, dynamic>> phoneRules = {
    "Cameroon": {"code": "+237", "length": 9},
    "Nigeria": {"code": "+234", "length": 10},
    "Ghana": {"code": "+233", "length": 9},
    "Kenya": {"code": "+254", "length": 9},
  };

  void _handleWithdraw() {
    final double? amount = double.tryParse(_amountController.text);

    if (amount == null || _phoneController.text.isEmpty || _pinController.text.isEmpty) {
      _showSnackBar("Please fill all fields", Colors.redAccent);
      return;
    }

    if (amount > widget.currentBalance) {
      _showSnackBar("Insufficient balance", Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    // Simulate withdraw processing offline
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        _showSnackBar("Successfully withdrawn ${amount.toStringAsFixed(0)} FCFA", Colors.green);
      }
    });
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
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
                          const Icon(Icons.outbox_rounded, size: 60, color: Color(0xFFE2C08D)),
                          const SizedBox(height: 15),
                          const Text("Withdraw Funds", 
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          const Text("Transfer money to your mobile account", 
                            style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 30),

                          // Country Selector
                          _buildDropdown(),
                          const SizedBox(height: 20),

                          // Phone Input
                          _buildInput(_phoneController, "Recipient Phone", Icons.phone_android, isNum: true),
                          const SizedBox(height: 20),

                          // Amount Input
                          _buildInput(_amountController, "Amount (FCFA)", Icons.money_off_rounded, isNum: true),
                          const SizedBox(height: 20),

                          // PIN Input
                          _buildInput(_pinController, "Secure PIN", Icons.lock_outline, isObscure: true, isNum: true),
                          
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

  Widget _buildBackground() => Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment.center, radius: 1.5, colors: [Color(0xFF1B3B44), Color(0xFF0F171A)])));

  Widget _buildAppBar(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: child,
      ),
    ),
  );

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCountry,
          dropdownColor: const Color(0xFF0F171A),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.cyan),
          items: phoneRules.keys.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              selectedCountry = val!;
              countryCode = phoneRules[val]!["code"];
            });
          },
        ),
      ),
    );
  }

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
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF005A6E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        side: const BorderSide(color: Color(0xFFE2C08D)),
      ),
      child: _isLoading 
        ? const CircularProgressIndicator(color: Colors.white)
        : Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    ),
  );
}