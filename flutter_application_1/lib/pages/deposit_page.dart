import 'package:flutter/material.dart';

class DepositPage extends StatefulWidget {
  final double currentBalance;

  const DepositPage({super.key, required this.currentBalance});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  String selectedCountry = "Cameroon";
  String countryCode = "+237";

  String? errorMessage;

  // Phone validation rules
  final Map<String, Map<String, dynamic>> phoneRules = {
    "Cameroon": {"code": "+237", "length": 9, "starts": ["6", "2"]},
    "Nigeria": {"code": "+234", "length": 10, "starts": ["7", "8", "9"]},
    "Ghana": {"code": "+233", "length": 9, "starts": ["2", "5"]},
    "Kenya": {"code": "+254", "length": 9, "starts": ["7"]},
    "South Africa": {"code": "+27", "length": 9, "starts": ["6", "7"]},
    "India": {"code": "+91", "length": 10, "starts": ["6", "7", "8", "9"]},
  };

  bool validatePhoneNumber() {
    String number = _phoneController.text.trim();

    var rules = phoneRules[selectedCountry]!;
    int requiredLength = rules["length"];
    List<dynamic> startsWith = rules["starts"];

    if (number.length != requiredLength) {
      setState(() {
        errorMessage =
            "Phone number must be $requiredLength digits for $selectedCountry.";
      });
      return false;
    }

    bool prefixValid = startsWith.any((prefix) => number.startsWith(prefix));

    if (!prefixValid) {
      setState(() {
        errorMessage =
            "Phone number must start with ${startsWith.join(" or ")} for $selectedCountry.";
      });
      return false;
    }

    return true;
  }

  void _handleDeposit() {
    if (!validatePhoneNumber()) return;

    if (_amountController.text.trim().isEmpty) {
      setState(() => errorMessage = "Please enter an amount.");
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      setState(() => errorMessage = "Enter a valid amount.");
      return;
    }

    setState(() => errorMessage = null);

    String fullNumber =
        "${phoneRules[selectedCountry]!["code"]} ${_phoneController.text.trim()}";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Deposit Successful"),
        content: Text(
            "You deposited ${amount.toStringAsFixed(0)} FCFA\nPhone: $fullNumber"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF39A9A9),

      appBar: AppBar(
        backgroundColor: const Color(0xFF39A9A9),
        elevation: 0,
        title: const Text("Deposit"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), //  BACK TO HOME
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Deposit",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // Country selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedCountry,
                underline: const SizedBox(),
                items: phoneRules.keys.map((country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value!;
                    countryCode = phoneRules[value]!["code"];
                  });
                },
              ),
            ),

            const SizedBox(height: 15),

            // Phone input
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText:
                    "Phone Number (${phoneRules[selectedCountry]!["code"]})",
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "Deposit Amount (FCFA)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // PIN
            TextField(
              controller: _pinController,
              obscureText: true,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "PIN Code",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            if (errorMessage != null)
              Text(errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14)),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleDeposit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text("Deposit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
