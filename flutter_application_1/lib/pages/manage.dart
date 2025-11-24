import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFF39A9A9),

      appBar: AppBar(
        backgroundColor: const Color(0xFF39A9A9),
        elevation: 0,
        title: Column(
          children: [
            const Text(
              "Manage Money",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (result != null)
              Text(
                "Current balance per day: ${result!.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // MANAGEMENT TITLE
            const Text(
              "Management",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // INPUT: Money amount
            TextField(
              controller: moneyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter money amount",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // INPUT: Days amount
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter number of days",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // MANAGE BUTTON
            ElevatedButton(
              onPressed: manageMoney,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text(
                "Manage",
                style: TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 30),

            // RESULT
            if (result != null)
              Text(
                "Daily amount: ${result!.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
