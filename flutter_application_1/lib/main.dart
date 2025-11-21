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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double balance = 50000; // INITIAL BALANCE

  // Call this when deposit page returns a value
  void addToBalance(double amount) {
    setState(() {
      balance += amount;
    });
  }

  // Call this when withdraw page returns a value
  void subtractFromBalance(double amount) {
    setState(() {
      balance -= amount;
    });
  }

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

            // SHOW DYNAMIC BALANCE
            Text(
              "Balance: ${balance.toStringAsFixed(0)} FCFA",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 40),

            // GO TO DEPOSIT PAGE
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 50),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DepositPage(currentBalance: balance),
                  ),
                );

                if (result != null && result is double) {
                  addToBalance(result);
                }
              },
              child: const Text("Deposit"),
            ),

            const SizedBox(height: 20),

            // GO TO WITHDRAW PAGE
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 50),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WithdrawPage(currentBalance: balance),
                  ),
                );

                if (result != null && result is double) {
                  subtractFromBalance(result);
                }
              },
              child: const Text("Withdraw"),
            ),
          ],
        ),
      ),
    );
  }
}
