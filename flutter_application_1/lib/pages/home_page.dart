import 'package:flutter/material.dart';
import 'database_helper.dart';
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
  late String username;
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Setup initial data from the login redirect
    userId = widget.user['id'];
    username = widget.user['username'] ?? "User";
    currentBalance = (widget.user['balance'] as num).toDouble();
    
    _refreshData();
  }

  /// REFRESH LOGIC: Keeps balance and list in sync with Database
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    
    // Fetch latest user info for the balance
    final userData = await DatabaseHelper.instance.getUser(widget.user['email']);
    // Fetch transaction history
    final history = await DatabaseHelper.instance.getTransactions(userId);

    if (mounted) {
      setState(() {
        if (userData != null) {
          currentBalance = (userData['balance'] as num).toDouble();
        }
        _recentTransactions = history;
        _isLoading = false;
      });
    }
  }

  /// NAVIGATION WRAPPER: Ensures data refreshes when returning to Home
  void _navigateTo(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    _refreshData(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F171A),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: Colors.cyan,
              backgroundColor: const Color(0xFF1B3B44),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh works
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 25),
                    _buildBalanceCard(),
                    const SizedBox(height: 35),
                    _sectionLabel("Quick Actions"),
                    const SizedBox(height: 15),
                    _buildActionGrid(),
                    const SizedBox(height: 40),
                    _sectionLabel("Recent Activity"),
                    const SizedBox(height: 15),
                    _buildTransactionList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE WIDGETS ---

  Widget _sectionLabel(String text) => Text(
    text, 
    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
  );

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
          Text(username, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
      GestureDetector(
        onTap: () => _navigateTo(ProfileScreen(user: widget.user)),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 2)
          ),
          child: const CircleAvatar(
            backgroundColor: Colors.transparent, 
            child: Icon(Icons.person, color: Colors.cyan),
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
      gradient: const LinearGradient(colors: [Color(0xFF005A6E), Color(0xFF1B3B44)]),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("TOTAL BALANCE", 
          style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
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
          height: 65, width: 65,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    ),
  );

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyan));
    }
    if (_recentTransactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 30),
          child: Text("No transactions yet", style: TextStyle(color: Colors.white38)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentTransactions.length > 5 ? 5 : _recentTransactions.length,
      itemBuilder: (context, index) {
        final tx = _recentTransactions[index];
        final bool isDeposit = tx['type'] == 'deposit';
        return _transactionTile(
          isDeposit ? "Wallet Refill" : "Money Withdrawal", 
          tx['date'].toString().substring(0, 10), // Shows YYYY-MM-DD
          "${isDeposit ? '+' : '-'} ${tx['amount']}", 
          isDeposit ? Colors.greenAccent : Colors.white
        );
      },
    );
  }

  Widget _transactionTile(String title, String subtitle, String amt, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.03), 
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(color == Colors.greenAccent ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: 16),
            ),
            const SizedBox(width: 15),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ]),
          ],
        ),
        Text("$amt FCFA", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    ),
  );
}