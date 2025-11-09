import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_helper.dart';
import '../../domain/entities/validation_result.dart';

class ScanHistoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  /// Guarda un resultado de validación en el historial local
  Future<void> saveScanResult(
    ValidationResult result,
    String validatedBy,
  ) async {
    final db = await _databaseHelper.database;

    await db.insert('validation_history', {
      'validationCode': result.validationCode ?? '',
      'eventId':
          '', // Por ahora vacío, se puede agregar eventId si está disponible
      'isValid': result.ticketStatus == 'valid' ? 1 : 0,
      'status': result.ticketStatus,
      'message': _getStatusMessage(result.ticketStatus),
      'participantName': result.participantName,
      'participantEmail': '', // Agregar si está disponible en el resultado
      'validatedAt': DateTime.now().toIso8601String(),
      'validatedBy': validatedBy,
      'isSynced': 0,
      // Campos adicionales para almacenar toda la información
      'participantDocument': result.participantDocument,
      'documentType': result.documentType,
      'participantStatus': result.participantStatus,
      'ticketCorrelative': result.ticketCorrelative,
      'categoryName': result.categoryName,
      'ticketName': result.ticketName ?? '',
      'eventName': result.eventName,
      'purchaseDate': result.purchaseDate?.toIso8601String(),
      'originalValidatedAt': result.validatedAt?.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Obtiene todo el historial de validaciones
  Future<List<ValidationResult>> getScanHistory() async {
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'validation_history',
      orderBy: 'validatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return ValidationResult(
        eventName: map['eventName'] ?? '',
        participantName: map['participantName'] ?? '',
        participantDocument: map['participantDocument'] ?? '',
        documentType: map['documentType'] ?? 'rut',
        participantStatus: map['participantStatus'] ?? 'unknown',
        ticketCorrelative: map['ticketCorrelative'] ?? 0,
        ticketStatus: map['status'] ?? 'unknown',
        validatedAt: map['originalValidatedAt'] != null
            ? DateTime.parse(map['originalValidatedAt'])
            : null,
        categoryName: map['categoryName'] ?? '',
        ticketName: map['ticketName'],
        purchaseDate: map['purchaseDate'] != null
            ? DateTime.parse(map['purchaseDate'])
            : null,
        validationCode: map['validationCode'],
      );
    });
  }

  /// Limpia todo el historial
  Future<void> clearHistory() async {
    final db = await _databaseHelper.database;
    await db.delete('validation_history');
  }

  /// Elimina una entrada específica del historial
  Future<void> deleteHistoryEntry(String validationCode) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'validation_history',
      where: 'validationCode = ?',
      whereArgs: [validationCode],
    );
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'valid':
        return 'Ticket válido, listo para usar';
      case 'validated':
        return 'Ticket ya validado y utilizado';
      case 'expired':
        return 'Ticket expirado';
      case 'invalid_replaced':
        return 'Ticket inválido - fue reemplazado';
      case 'invalid_cancelled':
        return 'Ticket inválido - fue cancelado';
      case 'invalid':
        return 'Ticket inválido';
      default:
        return 'Estado desconocido';
    }
  }
}
