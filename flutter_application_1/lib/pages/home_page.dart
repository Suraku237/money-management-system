import 'package:flutter/material.dart';
import 'database_helper.dart'; // Make sure this import is correct
import 'deposit_page.dart';
import 'withdraw_page.dart';
import 'manage.dart';
import 'profile_screen.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double currentBalance;
  late int userId;
  String username = "User";

  @override
  void initState() {
    super.initState();
    // Initialize with data passed from Login screen
    userId = widget.user['id'];
    username = widget.user['username'] ?? "User";
    currentBalance = (widget.user['balance'] as num).toDouble();
    
    // Immediately fetch the freshest data from DB
    _refreshBalance();
  }

  // Fetch the latest balance directly from the local database
  Future<void> _refreshBalance() async {
    final data = await DatabaseHelper.instance.getUser(widget.user['email']);
    if (data != null) {
      setState(() {
        currentBalance = (data['balance'] as num).toDouble();
      });
    }
  }

  // Standardized navigation that refreshes the UI when returning
  void _navigateTo(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    _refreshBalance(); // Refresh balance when user comes back from any action
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F171A),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 25),
                  _buildBalanceCard(),
                  const SizedBox(height: 35),
                  
                  const Text("Quick Actions", 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  _buildActionGrid(),
                  
                  const SizedBox(height: 40),
                  const Text("Recent Activity", 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildTransactionList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildBackground() => Container(
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.center, 
        radius: 1.5, 
        colors: [Color(0xFF1B3B44), Color(0xFF0F171A)]
      )
    )
  );

  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Welcome back,", style: TextStyle(color: Colors.white54, fontSize: 14)),
          Text(username, 
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 2),
          ),
          child: const CircleAvatar(
            backgroundColor: Color(0xFF1B3B44), 
            child: Icon(Icons.person, color: Colors.cyan)
          ),
        ),
      )
    ],
  );

  Widget _buildBalanceCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF005A6E), Color(0xFF1B3B44)]
      ),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("TOTAL BALANCE", 
          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Text("${currentBalance.toStringAsFixed(0)} FCFA", 
          style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _buildActionGrid() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _actionItem("Deposit", Icons.add_rounded, Colors.greenAccent, 
        () => _navigateTo(DepositPage(currentBalance: currentBalance, userId: userId))),
      
      _actionItem("Withdraw", Icons.remove_rounded, Colors.orangeAccent, 
        () => _navigateTo(WithdrawPage(currentBalance: currentBalance, userId: userId))),
      
      _actionItem("Manage", Icons.analytics_rounded, Colors.purpleAccent, 
        () => _navigateTo(ManagePage(currentBalance: currentBalance, userId: userId))),
    ],
  );

  Widget _actionItem(String label, IconData icon, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    ),
  );

  Widget _buildTransactionList() {
    // This part can be updated later to fetch real data from the 'transactions' table
    return Column(
      children: [
        _transactionTile("Mobile Money", "Deposit", "+ 5,000", Colors.greenAccent),
        _transactionTile("Supermarket", "Withdraw", "- 1,200", Colors.white),
        _transactionTile("Subscription", "Withdraw", "- 500", Colors.white),
      ],
    );
  }

  Widget _transactionTile(String title, String type, String amt, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.03), 
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.02))
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(type == "Deposit" ? Icons.south_west : Icons.north_east, color: color, size: 18),
            ),
            const SizedBox(width: 15),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(type, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
          ],
        ),
        Text("$amt FCFA", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    ),
  );
}