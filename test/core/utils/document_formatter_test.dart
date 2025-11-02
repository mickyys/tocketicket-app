import 'package:flutter_test/flutter_test.dart';
import 'package:tocke/core/utils/document_formatter.dart';

void main() {
  group('DocumentFormatter', () {
    group('formatDocument', () {
      test('should format RUT correctly', () {
        const document = '123456789';
        const documentType = 'rut';

        final result = DocumentFormatter.formatDocument(document, documentType);

        expect(result, equals('12.345.678-9'));
      });

      test('should not format passport', () {
        const document = 'PP1234567';
        const documentType = 'pasaporte';

        final result = DocumentFormatter.formatDocument(document, documentType);

        expect(result, equals('PP1234567'));
      });
    });

    group('formatRut', () {
      test('should format RUT with dots and dash', () {
        expect(
          DocumentFormatter.formatRut('123456789'),
          equals('12.345.678-9'),
        );
        expect(
          DocumentFormatter.formatRut('987654321'),
          equals('98.765.432-1'),
        );
        expect(
          DocumentFormatter.formatRut('12345678K'),
          equals('12.345.678-K'),
        );
      });

      test('should clean existing formatting before reformatting', () {
        expect(
          DocumentFormatter.formatRut('12.345.678-9'),
          equals('12.345.678-9'),
        );
        expect(
          DocumentFormatter.formatRut('12345678-9'),
          equals('12.345.678-9'),
        );
        expect(
          DocumentFormatter.formatRut('12 345 678-9'),
          equals('12.345.678-9'),
        );
      });

      test('should return original for very short input', () {
        expect(DocumentFormatter.formatRut('1'), equals('1'));
        expect(DocumentFormatter.formatRut(''), equals(''));
      });
    });

    group('getDocumentTypeDisplay', () {
      test('should return correct display names', () {
        expect(DocumentFormatter.getDocumentTypeDisplay('rut'), equals('RUT'));
        expect(
          DocumentFormatter.getDocumentTypeDisplay('pasaporte'),
          equals('Pasaporte'),
        );
        expect(
          DocumentFormatter.getDocumentTypeDisplay('cedula'),
          equals('CEDULA'),
        );
      });
    });

    group('cleanDocument', () {
      test('should remove all formatting characters', () {
        expect(
          DocumentFormatter.cleanDocument('12.345.678-9'),
          equals('123456789'),
        );
        expect(
          DocumentFormatter.cleanDocument('12 345 678-9'),
          equals('123456789'),
        );
        expect(
          DocumentFormatter.cleanDocument('PP-123.456'),
          equals('PP123456'),
        );
      });
    });
  });
}
