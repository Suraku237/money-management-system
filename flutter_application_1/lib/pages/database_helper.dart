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
      // This ensures foreign keys work (needed for linking transactions to users)
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
        balance REAL DEFAULT 0.0
      )
    ''');

    // 2. Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        type TEXT, -- 'deposit' or 'withdraw'
        amount REAL,
        date TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- ACTIONS ---

  // Create a new user
  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('users', row);
  }

  // Verify Login
  Future<Map<String, dynamic>?> checkUser(String email, String password) async {
    final db = await instance.database;
    final results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Get fresh user data (used for Home Page refresh)
  Future<Map<String, dynamic>?> getUser(String email) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // The "Engine": Updates balance and logs history in one go
  Future<void> updateBalance(int userId, double amount, String type) async {
    final db = await instance.database;

    // Use a transaction to ensure both steps happen or neither happens
    await db.transaction((txn) async {
      // 1. Update the balance
      await txn.rawUpdate(
        'UPDATE users SET balance = balance + ? WHERE id = ?',
        [type == 'deposit' ? amount : -amount, userId],
      );

      // 2. Create the history record
      await txn.insert('transactions', {
        'user_id': userId,
        'type': type,
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
      });
    });
  }

  // Get transaction history for the user
  Future<List<Map<String, dynamic>>> getTransactions(int userId) async {
    final db = await instance.database;
    return await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }
}