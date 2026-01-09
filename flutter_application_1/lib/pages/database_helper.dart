import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('money_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1, 
      onCreate: _createDB,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE,
        pin TEXT NOT NULL UNIQUE,
        balance REAL DEFAULT 0.0
      )
    ''');

    // 2. Transactions Table
  await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      type TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id)
    )
  ''');
  }

  // --- AUTHENTICATION METHODS ---

  // For Signup: Adds a new user
  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('users', row);
  }

  // For Login: Checks credentials
  Future<Map<String, dynamic>?> checkUser(String email, String password) async {
    final db = await instance.database;
    final res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // For Refreshing Home Page: Gets latest user data by email
  Future<Map<String, dynamic>?> getUser(String email) async {
    final db = await instance.database;
    final res = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return res.isNotEmpty ? res.first : null;
  }

  // --- TRANSACTION METHODS ---

  // For Deposit/Withdraw: Handles balance updates and history logging
  Future<void> updateBalance({
    required int userId, 
    required double amount, 
    required String type, 
    required String providedPhone,
    required String providedPin,
  }) async {
    final db = await instance.database;

    final userList = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (userList.isEmpty) throw Exception("User not found");
    
    final user = userList.first;
    final String registeredPhone = user['phone'] as String;
    final String registeredPin = user['pin'] as String;
    final double currentBalance = (user['balance'] as num).toDouble();

    // Logic: Withdrawals must match registered Phone/PIN
    if (type == 'withdraw') {
      if (providedPhone != registeredPhone) {
        throw Exception("Withdrawal only allowed with registered phone: $registeredPhone");
      }
      if (providedPin != registeredPin) {
        throw Exception("Incorrect PIN code");
      }
      if (currentBalance < amount) {
        throw Exception("Insufficient balance");
      }
    }

    await db.transaction((txn) async {
      // Update Balance
      await txn.rawUpdate(
        'UPDATE users SET balance = balance + ? WHERE id = ?',
        [type == 'deposit' ? amount : -amount, userId],
      );

      // Insert History Record
      await txn.insert('transactions', {
        'user_id': userId,
        'type': type,
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
      });
    });
  }

  // For Home Page Activity: Gets history for a specific user
  Future<List<Map<String, dynamic>>> getTransactions(int userId) async {
    final db = await instance.database;
    return await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  // For Manage Page: Deletes a specific transaction
  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}