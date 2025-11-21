import 'package:flutter/material.dart';
import 'pages/deposit_page.dart';
import 'pages/withdraw_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final double balance = 0; // Your initial balance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF39A9A9),

      appBar: AppBar(
        title: const Text("Money Manager"),
        backgroundColor: const Color(0xFF39A9A9),
        elevation: 0,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // BALANCE DISPLAY
            Text(
              "Balance: ${balance.toStringAsFixed(0)} FCFA",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 40),

            // DEPOSIT BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DepositPage(
                      currentBalance: balance,
                    ),
                  ),
                );
              },
              child: const Text("Deposit"),
            ),

            const SizedBox(height: 20),

            // WITHDRAW BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WithdrawPage(
                      currentBalance: balance,
                    ),
                  ),
                );
              },
              child: const Text("Withdraw"),
            ),
          ],
        ),
      ),
    );
  }
}
