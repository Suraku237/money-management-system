import 'package:flutter/material.dart';
import 'dart:io'; // Required for File
import 'deposit_page.dart';
import 'withdraw_page.dart';
import 'manage.dart';
import 'profile_screen.dart'; 

class HomePage extends StatefulWidget {
  final double currentBalance;

  const HomePage({super.key, required this.currentBalance});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // If you want the image to persist across screens, 
  // you would ideally use a Global State or pass it back.
  File? _profileImage; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F171A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "My Wallet",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () async {
                // Navigate to Profile Screen
                // We 'await' the result if you decide to pass the image back
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                backgroundColor: const Color(0xFF005A6E),
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null 
                    ? const Icon(Icons.person, color: Colors.white) 
                    : null,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sleek Balance Card
              _buildBalanceCard(),

              const SizedBox(height: 30),

              // 2. Quick Actions Section
              const Text(
                "Quick Actions",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _actionButton(context, "Deposit", Icons.add_circle_outline, const Color(0xFFE2C08D), () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => DepositPage(currentBalance: widget.currentBalance)));
                  }),
                  _actionButton(context, "Withdraw", Icons.remove_circle_outline, Colors.cyan, () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => WithdrawPage(currentBalance: widget.currentBalance)));
                  }),
                  _actionButton(context, "Manage", Icons.pie_chart_outline, Colors.purpleAccent, () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const ManagePage()));
                  }),
                ],
              ),

              const SizedBox(height: 35),

              // 3. Recent Transactions Section
              _buildRecentTransactionsHeader(),
              const SizedBox(height: 10),

              _transactionItem("Supermarket", "Shopping", "- 15,000 FCFA", Icons.shopping_bag, Colors.orange),
              _transactionItem("Salary Deposit", "Work", "+ 250,000 FCFA", Icons.work, Colors.green),
              _transactionItem("Internet Bill", "Utilities", "- 10,000 FCFA", Icons.wifi, Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Sub-Widgets for Cleaner Code ---

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF005A6E), Color(0xFF1B3B44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 10),
          Text(
            "${widget.currentBalance.toStringAsFixed(0)} FCFA",
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 18),
              Text(" +2.5% this month", style: TextStyle(color: Colors.greenAccent)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Recent Transactions",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: Colors.cyan))),
      ],
    );
  }

  Widget _actionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 70, width: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }

  Widget _transactionItem(String title, String category, String amount, IconData icon, Color iconBg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconBg),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(category, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              color: amount.contains('+') ? Colors.greenAccent : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}