import 'package:flutter_test/flutter_test.dart';
import 'package:tocke/core/utils/document_formatter.dart';

void main() {
  group('DocumentFormatter', () {
    test('Debe formatear un RUT chileno correctamente', () {
      expect(DocumentFormatter.formatRut('123456789'), '12.345.678-9');
      expect(DocumentFormatter.formatRut('12345678K'), '12.345.678-K');
      expect(DocumentFormatter.formatRut('1234567-8'), '1.234.567-8');
    });

    test('Debe manejar RUTs ya formateados limpiándolos y re-formateándolos', () {
      expect(DocumentFormatter.formatRut('12.345.678-9'), '12.345.678-9');
    });

    test('Debe devolver el RUT original si es demasiado corto', () {
      expect(DocumentFormatter.formatRut('1'), '1');
    });

    test('Debe formatear correctamente según el tipo de documento', () {
      expect(DocumentFormatter.formatDocument('123456789', 'rut'), '12.345.678-9');
      expect(DocumentFormatter.formatDocument('ABC123456', 'pasaporte'), 'ABC123456');
    });

    test('Debe limpiar documentos correctamente', () {
      expect(DocumentFormatter.cleanDocument('12.345.678-9'), '123456789');
      expect(DocumentFormatter.cleanDocument('  ABC 123  '), 'ABC123');
    });
  });
}
