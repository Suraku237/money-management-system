import 'package:flutter/material.dart';
import 'deposit_page.dart';
import 'withdraw_page.dart';
import 'manage.dart';

class HomePage extends StatelessWidget {
  final double currentBalance;

  const HomePage({super.key, required this.currentBalance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF39A9A9),

      appBar: AppBar(
        backgroundColor: const Color(0xFF39A9A9),
        elevation: 0,
        title: const Text(
          "My Wallet",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Current Balance",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${currentBalance.toStringAsFixed(0)} FCFA",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // First Row: Deposit + Withdraw
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                // Deposit Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DepositPage(currentBalance: currentBalance),
                      ),
                    );
                  },
                  child: _homeButton(
                    icon: Icons.arrow_downward,
                    label: "Deposit",
                    color: Colors.white,
                    textColor: Colors.black,
                  ),
                ),

                // Withdraw Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WithdrawPage(currentBalance: currentBalance),
                      ),
                    );
                  },
                  child: _homeButton(
                    icon: Icons.arrow_upward,
                    label: "Withdraw",
                    color: Colors.white,
                    textColor: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30), // space between rows

            // Second Row: Manage (centered)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManagePage(),
                      ),
                    );
                  },
                  child: _homeButton(
                    icon: Icons.account_balance,
                    label: "Manage",
                    color: Colors.white,
                    textColor: Colors.black,
                  ),
                )
              ],
            ),

            const SizedBox(height: 40),

            const Text(
              "Choose an action to continue.",
              style: TextStyle(color: Colors.white, fontSize: 15),
            )
          ],
        ),
      ),
    );
  }

  // Button Widget
  Widget _homeButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: textColor),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
