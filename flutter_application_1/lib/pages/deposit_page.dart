import 'package:flutter/material.dart';

class DepositPage extends StatefulWidget {
  final double currentBalance;

  const DepositPage({super.key, required this.currentBalance});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  String? errorMessage;
  String selectedCountry = "Cameroon (+237)";

  // Country phone patterns
  final Map<String, Map<String, dynamic>> phoneRules = {
    "Cameroon (+237)": {
      "length": 9,
      "startsWith": ["6"],
    },
    "Nigeria (+234)": {
      "length": 10,
      "startsWith": ["7", "8", "9"],
    },
    "Ghana (+233)": {
      "length": 9,
      "startsWith": ["2", "5"],
    },
  };

  void _handleDeposit() {
    final amount = double.tryParse(_amountController.text.trim());
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    if (amount == null || amount <= 0) {
      setState(() => errorMessage = "Enter a valid amount.");
      return;
    }

    final rules = phoneRules[selectedCountry]!;
    if (phone.length != rules["length"] ||
        !rules["startsWith"].contains(phone[0])) {
      setState(() => errorMessage = "Invalid phone number for $selectedCountry.");
      return;
    }

    if (pin.length != 4) {
      setState(() => errorMessage = "PIN must be 4 digits.");
      return;
    }

    Navigator.pop(context, amount); // RETURN TO MAIN WITH AMOUNT
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF39A9A9),

      appBar: AppBar(
        title: const Text("Deposit"),
        backgroundColor: const Color(0xFF39A9A9),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Deposit",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField(
              value: selectedCountry,
              dropdownColor: Colors.white,
              items: phoneRules.keys.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedCountry = value!);
              },
              decoration: const InputDecoration(
                labelText: "Select Country",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter your number",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Deposit Amount",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "PIN Code",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),

            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleDeposit,
                child: const Text("Deposit"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
