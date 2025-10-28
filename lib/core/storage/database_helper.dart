import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        lastName TEXT NOT NULL,
        phone TEXT,
        profileImage TEXT,
        role TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        isEmailVerified INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT,
        updatedAt TEXT,
        token TEXT,
        refreshToken TEXT
      )
    ''');

    // Create events table
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        location TEXT NOT NULL,
        address TEXT NOT NULL,
        organizerId TEXT NOT NULL,
        imageUrl TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        isPublic INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT,
        updatedAt TEXT,
        lastSyncAt TEXT
      )
    ''');

    // Create orders table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        eventId TEXT NOT NULL,
        userId TEXT NOT NULL,
        ticketId TEXT NOT NULL,
        validationCode TEXT NOT NULL UNIQUE,
        status TEXT NOT NULL DEFAULT 'pending',
        validatedAt TEXT,
        validatedBy TEXT,
        totalAmount REAL NOT NULL,
        participantName TEXT NOT NULL,
        participantEmail TEXT NOT NULL,
        participantPhone TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        isSynced INTEGER NOT NULL DEFAULT 1,
        lastSyncAt TEXT,
        FOREIGN KEY (eventId) REFERENCES events (id) ON DELETE CASCADE
      )
    ''');

    // Create validation_history table
    await db.execute('''
      CREATE TABLE validation_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        validationCode TEXT NOT NULL,
        eventId TEXT NOT NULL,
        isValid INTEGER NOT NULL,
        status TEXT NOT NULL,
        message TEXT NOT NULL,
        participantName TEXT,
        participantEmail TEXT,
        validatedAt TEXT NOT NULL,
        validatedBy TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (eventId) REFERENCES events (id) ON DELETE CASCADE
      )
    ''');

    // Create sync_queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        lastAttempt TEXT,
        isProcessed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_orders_event_id ON orders (eventId)');
    await db.execute(
      'CREATE INDEX idx_orders_validation_code ON orders (validationCode)',
    );
    await db.execute(
      'CREATE INDEX idx_validation_history_event_id ON validation_history (eventId)',
    );
    await db.execute(
      'CREATE INDEX idx_sync_queue_processed ON sync_queue (isProcessed)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
