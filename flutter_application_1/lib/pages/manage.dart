import 'package:flutter/material.dart';
import 'dart:ui';

class ManagePage extends StatefulWidget {
  final double currentBalance;
  final int userId;

  // Receives live data from the database via HomePage
  const ManagePage({super.key, required this.currentBalance, required this.userId});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  final TextEditingController daysController = TextEditingController();
  double? result;

  void manageMoney() {
    // We use widget.currentBalance directly for the calculation
    final int? days = int.tryParse(daysController.text);

    if (days == null || days <= 0) {
      setState(() {
        result = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid number of days"), 
          backgroundColor: Colors.orange
        ),
      );
      return;
    }

    setState(() {
      // Logic: Actual Database Balance divided by Days remaining
      result = widget.currentBalance / days;
    });
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
                          const Icon(Icons.auto_graph_rounded, size: 60, color: Color(0xFFE2C08D)),
                          const SizedBox(height: 15),
                          const Text("Budget Planner", 
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          const Text("Smart spending based on your balance", style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 30),

                          // Displays the LIVE balance from the database
                          _buildBalanceDisplay(),
                          
                          const SizedBox(height: 25),
                          _buildInput(daysController, "How many days should this last?", Icons.timer_outlined),
                          
                          const SizedBox(height: 30),
                          _buildButton("CALCULATE DAILY LIMIT", manageMoney),

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

  // --- UI COMPONENTS ---

  Widget _buildBalanceDisplay() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.black26, 
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.white10)
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Wallet Balance:", style: TextStyle(color: Colors.white70)),
        Text("${widget.currentBalance.toStringAsFixed(0)} FCFA", 
          style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    ),
  );

  Widget _buildResultCard() => Container(
    margin: const EdgeInsets.only(top: 30),
    padding: const EdgeInsets.all(20),
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Colors.cyan.withOpacity(0.2), Colors.transparent]),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.cyan.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        const Text("DAILY SPENDING LIMIT", style: TextStyle(color: Colors.white70, letterSpacing: 1.2, fontSize: 12)),
        const SizedBox(height: 10),
        Text("${result!.toStringAsFixed(2)} FCFA", 
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        const Text("Stay under this to reach your goal", style: TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    ),
  );

  Widget _buildBackground() => Container(
    decoration: const BoxDecoration(
      gradient: RadialGradient(center: Alignment.center, radius: 1.5, colors: [Color(0xFF1B3B44), Color(0xFF0F171A)])
    )
  );

  Widget _buildAppBar(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        const Text("Manage Money", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildInput(TextEditingController controller, String hint, IconData icon) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
}