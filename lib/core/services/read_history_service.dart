import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/scanner/domain/entities/read_record.dart';

class ReadHistoryService {
  static const String _storageKey = 'readHistory';

  /// Obtener todo el historial de lecturas
  static Future<List<ReadRecord>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final records = jsonList
          .map((item) => ReadRecord.fromJson(item as Map<String, dynamic>))
          .toList();

      // Ordenar por timestamp descendente (más recientes primero)
      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return records;
    } catch (e) {
      print('Error loading read history: $e');
      return [];
    }
  }

  /// Agregar un nuevo registro al historial
  static Future<void> addRecord(ReadRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final records = await getHistory();
      records.insert(
        0,
        record,
      ); // Agregar al inicio para mantener orden descendente

      final jsonList = records.map((r) => r.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving read record: $e');
    }
  }

  /// Limpiar todo el historial
  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing read history: $e');
    }
  }

  /// Obtener cantidad de registros con isFirstTime = true
  static Future<int> getFirstTimeCount() async {
    final records = await getHistory();
    return records.where((r) => r.isFirstTime).length;
  }

  /// Obtener cantidad de registros con isFirstTime = false
  static Future<int> getUpdateCount() async {
    final records = await getHistory();
    return records.where((r) => !r.isFirstTime).length;
  }
}
