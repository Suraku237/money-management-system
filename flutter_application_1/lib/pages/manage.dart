import 'package:flutter/material.dart';
import 'dart:ui';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  final TextEditingController moneyController = TextEditingController();
  final TextEditingController daysController = TextEditingController();

  double? result;

  void manageMoney() {
    final double? money = double.tryParse(moneyController.text);
    final int? days = int.tryParse(daysController.text);

    if (money == null || days == null || days == 0) {
      setState(() {
        result = null;
      });
      return;
    }

    setState(() {
      result = money / days;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background matching Login/Home
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
                          const Icon(Icons.pie_chart, size: 60, color: Color(0xFFE2C08D)),
                          const SizedBox(height: 15),
                          const Text(
                            "Budget Planner",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const Text(
                            "Calculate your daily spending limit",
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 40),
                          
                          // Money Input
                          _buildInput(moneyController, "Total Amount (FCFA)", Icons.account_balance_wallet_outlined),
                          const SizedBox(height: 20),
                          
                          // Days Input
                          _buildInput(daysController, "Number of Days", Icons.calendar_today_outlined, isNum: true),
                          const SizedBox(height: 40),
                          
                          // Calculate Button
                          _buildButton("CALCULATE DAILY BUDGET", manageMoney),
                          
                          const SizedBox(height: 40),
                          
                          // Result Section
                          if (result != null) _buildResultCard(),
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

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text("Recommended Daily Spend", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            "${result!.toStringAsFixed(0)} FCFA",
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 5),
          const Text("Stay under this to reach your goal", style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  // UI Helper Components
  Widget _buildBackground() => Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment.center, radius: 1.5, colors: [Color(0xFF1B3B44), Color(0xFF0F171A)])));

  Widget _buildAppBar(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    child: Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
        const Text("Manage Money", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {bool isNum = true}) => TextField(
    controller: controller,
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
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF005A6E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        side: const BorderSide(color: Color(0xFFE2C08D)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    ),
  );
}