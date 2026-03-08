import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ParticipantDatabase {
  static final ParticipantDatabase _instance = ParticipantDatabase._internal();
  static Database? _database;

  ParticipantDatabase._internal();

  factory ParticipantDatabase() {
    return _instance;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'participant_cache.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migración de v1 a v2: agregar columnas faltantes
      await db.execute('ALTER TABLE participants ADD COLUMN eventName TEXT');
      await db.execute(
        'ALTER TABLE participants ADD COLUMN participantStatus TEXT',
      );
      await db.execute('ALTER TABLE participants ADD COLUMN purchaseDate TEXT');
      await db.execute('ALTER TABLE participants ADD COLUMN runnerNumber TEXT');
      await db.execute('ALTER TABLE participants ADD COLUMN chipId TEXT');
      await db.execute(
        'ALTER TABLE participants ADD COLUMN validationCode TEXT',
      );
    }
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE participants (
        id TEXT PRIMARY KEY,
        eventId TEXT NOT NULL,
        eventName TEXT,
        ticketCorrelative INTEGER,
        participantName TEXT NOT NULL,
        participantDocumentNumber TEXT NOT NULL,
        participantDocumentType TEXT,
        participantStatus TEXT,
        categoryName TEXT,
        ticketName TEXT,
        ticketStatus TEXT,
        purchaseDate TEXT,
        validatedAt TEXT,
        runnerNumber TEXT,
        chipId TEXT,
        validationCode TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        UNIQUE(eventId, ticketCorrelative)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_eventId ON participants(eventId);
    ''');

    await db.execute('''
      CREATE INDEX idx_participantName ON participants(participantName);
    ''');

    await db.execute('''
      CREATE INDEX idx_participantDocumentNumber ON participants(participantDocumentNumber);
    ''');
  }

  Future<int> insertParticipant(Map<String, dynamic> participant) async {
    final db = await database;
    return db.insert(
      'participants',
      participant,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertParticipants(
    List<Map<String, dynamic>> participants,
  ) async {
    final db = await database;
    final batch = db.batch();

    for (final participant in participants) {
      batch.insert(
        'participants',
        participant,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final results = await batch.commit();
    return results.length;
  }

  Future<List<Map<String, dynamic>>> getParticipantsByEvent(
    String eventId,
  ) async {
    final db = await database;
    return db.query(
      'participants',
      where: 'eventId = ?',
      whereArgs: [eventId],
      orderBy: 'participantName ASC',
    );
  }

  Future<List<Map<String, dynamic>>> searchParticipants(
    String eventId,
    String query,
  ) async {
    final db = await database;
    final searchTerm = '%$query%';

    return db.query(
      'participants',
      where:
          'eventId = ? AND (participantName LIKE ? OR participantDocumentNumber LIKE ?)',
      whereArgs: [eventId, searchTerm, searchTerm],
      orderBy: 'participantName ASC',
    );
  }

  Future<void> deleteParticipantsByEvent(String eventId) async {
    final db = await database;
    await db.delete('participants', where: 'eventId = ?', whereArgs: [eventId]);
  }

  Future<int> getParticipantCountByEvent(String eventId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM participants WHERE eventId = ?',
      [eventId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<String, dynamic>?> findByValidationCode(
    String validationCode,
  ) async {
    final db = await database;
    final results = await db.query(
      'participants',
      where: 'validationCode = ?',
      whereArgs: [validationCode],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> close() async {
    _database?.close();
  }
}
