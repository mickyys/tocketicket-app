import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:tocke/core/error/failures.dart';
import 'package:tocke/features/scanner/domain/entities/validation_result.dart';
import 'package:tocke/features/scanner/domain/usecases/check_ticket_status.dart';
import 'package:tocke/features/scanner/domain/usecases/validate_ticket_qr.dart';
import 'package:tocke/features/scanner/domain/usecases/update_ticket_runner_data.dart';
import 'package:tocke/features/scanner/presentation/bloc/scanner_bloc.dart';
import 'package:tocke/features/scanner/presentation/bloc/scanner_event.dart';
import 'package:tocke/features/scanner/presentation/bloc/scanner_state.dart';
import 'package:tocke/features/scanner/domain/repositories/ticket_repository.dart';

class MockTicketRepository implements TicketRepository {
  @override
  Future<Either<Failure, ValidationResult>> checkTicketStatus(String validationCode) => throw UnimplementedError();
  @override
  Future<Either<Failure, ValidationResult>> validateTicketQR(String validationCode) => throw UnimplementedError();
  @override
  Future<Either<Failure, ValidationResult>> updateTicketRunnerData(String validationCode, String runnerNumber, String chipId) => throw UnimplementedError();
}

class MockCheckTicketStatus implements CheckTicketStatus {
  late Either<Failure, ValidationResult> result;
  @override
  Future<Either<Failure, ValidationResult>> call(String validationCode) async => result;
  @override
  TicketRepository get repository => MockTicketRepository();
}

class MockValidateTicketQR implements ValidateTicketQR {
  late Either<Failure, ValidationResult> result;
  @override
  Future<Either<Failure, ValidationResult>> call(String validationCode) async => result;
  @override
  TicketRepository get repository => MockTicketRepository();
}

class MockUpdateTicketRunnerData implements UpdateTicketRunnerData {
  late Either<Failure, ValidationResult> result;
  @override
  Future<Either<Failure, ValidationResult>> call(UpdateTicketRunnerDataParams params) async => result;
  @override
  TicketRepository get repository => MockTicketRepository();
}

void main() {
  late ScannerBloc scannerBloc;
  late MockCheckTicketStatus mockCheckTicketStatus;
  late MockValidateTicketQR mockValidateTicketQR;
  late MockUpdateTicketRunnerData mockUpdateTicketRunnerData;

  const tValidationCode = 'VALID_CODE';
  const tValidationResult = ValidationResult(
    eventName: 'Test Event',
    participantName: 'John Doe',
    ticketStatus: 'active',
    categoryName: 'General',
    isValid: true,
  );

  setUp(() {
    mockCheckTicketStatus = MockCheckTicketStatus();
    mockValidateTicketQR = MockValidateTicketQR();
    mockUpdateTicketRunnerData = MockUpdateTicketRunnerData();
    scannerBloc = ScannerBloc(
      checkTicketStatus: mockCheckTicketStatus,
      validateTicketQR: mockValidateTicketQR,
      updateTicketRunnerData: mockUpdateTicketRunnerData,
    );
  });

  tearDown(() {
    scannerBloc.close();
  });

  test('El estado inicial debe ser ScannerInitial', () {
    expect(scannerBloc.state, equals(ScannerInitial()));
  });

  group('CheckTicketStatusEvent', () {
    test('Debe emitir [CheckingTicketStatus, TicketStatusLoaded] cuando la consulta es exitosa', () async {
      // arrange
      mockCheckTicketStatus.result = const Right(tValidationResult);
      
      // assert later
      final expected = [
        CheckingTicketStatus(tValidationCode),
        const TicketStatusLoaded(tValidationResult),
      ];
      expectLater(scannerBloc.stream, emitsInOrder(expected));

      // act
      scannerBloc.add(const CheckTicketStatusEvent(tValidationCode));
    });

    test('Debe emitir [CheckingTicketStatus, TicketNotFound] cuando el ticket no existe', () async {
      // arrange
      mockCheckTicketStatus.result = const Left(ServerFailure(errorMessage: 'Ticket no encontrado'));
      
      // assert later
      final expected = [
        CheckingTicketStatus(tValidationCode),
        TicketNotFound(tValidationCode),
      ];
      expectLater(scannerBloc.stream, emitsInOrder(expected));

      // act
      scannerBloc.add(const CheckTicketStatusEvent(tValidationCode));
    });

    test('Debe emitir [CheckingTicketStatus, ScannerError] cuando ocurre un error genérico', () async {
      // arrange
      mockCheckTicketStatus.result = const Left(ServerFailure(errorMessage: 'Error de servidor'));
      
      // assert later
      final expected = [
        CheckingTicketStatus(tValidationCode),
        const ScannerError('Error consultando ticket: ServerFailure(Error de servidor)'),
      ];
      expectLater(scannerBloc.stream, emitsInOrder(expected));

      // act
      scannerBloc.add(const CheckTicketStatusEvent(tValidationCode));
    });
  });

  group('ConfirmValidationEvent', () {
    test('Debe emitir [ValidatingTicket, ValidationSuccess] cuando la validación es exitosa', () async {
      // arrange
      final successResult = ValidationResult(
        eventName: tValidationResult.eventName,
        participantName: tValidationResult.participantName,
        ticketStatus: 'used',
        categoryName: tValidationResult.categoryName,
        isValid: true,
      );
      mockValidateTicketQR.result = Right(successResult);
      
      // assert later
      final expected = [
        ValidatingTicket(tValidationCode),
        ValidationSuccess(successResult),
      ];
      expectLater(scannerBloc.stream, emitsInOrder(expected));

      // act
      scannerBloc.add(const ConfirmValidationEvent(tValidationCode));
    });

    test('Debe emitir [ValidatingTicket, ScannerError] cuando falla la validación', () async {
      // arrange
      mockValidateTicketQR.result = const Left(ServerFailure(errorMessage: 'Error al validar'));
      
      // assert later
      final expected = [
        ValidatingTicket(tValidationCode),
        const ScannerError('Error validando ticket: ServerFailure(Error al validar)'),
      ];
      expectLater(scannerBloc.stream, emitsInOrder(expected));

      // act
      scannerBloc.add(const ConfirmValidationEvent(tValidationCode));
    });
  });

  group('ScanQRCode', () {
    test('Debe extraer el código de una URL y disparar CheckTicketStatusEvent', () async {
      // arrange
      mockCheckTicketStatus.result = const Right(tValidationResult);
      final tUrl = 'https://tocke.cl/validation?code=$tValidationCode';
      
      // assert later
      final expected = [
        CheckingTicketStatus(tValidationCode),
        const TicketStatusLoaded(tValidationResult),
      ];
      expectLater(scannerBloc.stream, emitsInOrder(expected));

      // act
      scannerBloc.add(ScanQRCode(tUrl));
    });

    test('Debe emitir ScannerError si el QR es inválido (vacío)', () async {
      // assert later
      final expected = [
        const ScannerError('Código QR inválido'),
      ];
      expectLater(scannerBloc.stream, emitsInOrder(expected));

      // act
      scannerBloc.add(const ScanQRCode(''));
    });
  });
}
