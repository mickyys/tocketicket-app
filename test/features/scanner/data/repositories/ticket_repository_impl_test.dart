import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tocke/core/error/failures.dart';
import 'package:tocke/core/errors/exceptions.dart';
import 'package:tocke/core/network/network_info.dart';
import 'package:tocke/features/scanner/data/datasources/ticket_remote_data_source.dart';
import 'package:tocke/features/scanner/data/models/validation_result_model.dart';
import 'package:tocke/features/scanner/data/repositories/ticket_repository_impl.dart';
import 'package:tocke/features/scanner/domain/entities/validation_result.dart';

// Mock simple para NetworkInfo
class MockNetworkInfo implements NetworkInfo {
  bool isConnectedValue = true;
  @override
  Future<bool> get isConnected async => isConnectedValue;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => Stream.value([ConnectivityResult.wifi]);
}

// Mock simple para TicketRemoteDataSource
class MockTicketRemoteDataSource implements TicketRemoteDataSource {
  late dynamic result;
  
  @override
  Future<ValidationResultModel> checkTicketStatus(String validationCode) async {
    if (result is Exception) throw result;
    return result as ValidationResultModel;
  }

  @override
  Future<ValidationResultModel> validateTicketQR(String validationCode) async {
    if (result is Exception) throw result;
    return result as ValidationResultModel;
  }

  @override
  Future<ValidationResultModel> updateTicketRunnerData(String validationCode, String runnerNumber, String chipId) async {
    if (result is Exception) throw result;
    return result as ValidationResultModel;
  }
}

void main() {
  late TicketRepositoryImpl repository;
  late MockTicketRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockTicketRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = TicketRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tModel = ValidationResultModel(
    eventName: 'Test Event',
    participantName: 'John Doe',
    participantDocument: '12345678-9',
    documentType: 'rut',
    ticketStatus: 'active',
    categoryName: 'General',
    isValid: true,
  );

  group('Manejo de Conexión (Online Only)', () {
    test('Debe retornar ValidationFailure cuando no hay conexión a internet', () async {
      // arrange
      mockNetworkInfo.isConnectedValue = false;

      // act
      final result = await repository.checkTicketStatus('ANY_CODE');

      // assert
      expect(result, isA<Left<Failure, ValidationResult>>());
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Se requiere conexión a internet'));
        },
        (_) => fail('Debería haber fallado por falta de conexión'),
      );
    });

    test('Debe llamar al remoteDataSource cuando SÍ hay conexión', () async {
      // arrange
      mockNetworkInfo.isConnectedValue = true;
      mockRemoteDataSource.result = tModel;

      // act
      final result = await repository.checkTicketStatus('VALID_CODE');

      // assert
      expect(result.isRight(), true);
    });

    test('Debe manejar ServerException y retornar ValidationFailure con el mensaje del error', () async {
      // arrange
      mockNetworkInfo.isConnectedValue = true;
      mockRemoteDataSource.result = ServerException('Error del servidor 500');

      // act
      final result = await repository.checkTicketStatus('ANY_CODE');

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'Error del servidor 500'),
        (_) => fail('Debería haber retornado un failure'),
      );
    });
  });
}
