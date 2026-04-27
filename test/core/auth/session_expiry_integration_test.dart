import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tocke/features/scanner/presentation/bloc/scanner_bloc.dart';
import 'package:tocke/features/scanner/presentation/bloc/scanner_event.dart';
import 'package:tocke/features/scanner/presentation/bloc/scanner_state.dart';
import 'package:tocke/features/scanner/domain/usecases/check_ticket_status.dart';
import 'package:tocke/features/scanner/domain/usecases/validate_ticket_qr.dart';
import 'package:tocke/features/scanner/domain/usecases/update_ticket_runner_data.dart';
import 'package:tocke/features/scanner/data/datasources/ticket_remote_data_source.dart';
import 'package:tocke/features/scanner/data/repositories/ticket_repository_impl.dart';
import 'package:tocke/features/scanner/data/models/validation_result_model.dart';
import 'package:tocke/core/network/network_info.dart';
import 'package:tocke/core/errors/exceptions.dart';

class MockTicketRemoteDataSource implements TicketRemoteDataSource {
  @override
  Future<ValidationResultModel> checkTicketStatus(String validationCode) async {
    throw ServerException('Token de autenticación inválido'); // Simula 401
  }

  @override
  Future<ValidationResultModel> validateTicketQR(String validationCode) => throw UnimplementedError();

  @override
  Future<ValidationResultModel> updateTicketRunnerData(String validationCode, String runnerNumber, String chipId) => throw UnimplementedError();
}

class SimpleNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => Stream.value([ConnectivityResult.wifi]);
}

void main() {
  group('Sesión Expirada (401)', () {
    test('Debe emitir ScannerError con mensaje de token inválido cuando el servidor responde 401', () async {
      final remoteDataSource = MockTicketRemoteDataSource();
      final repository = TicketRepositoryImpl(
        remoteDataSource: remoteDataSource,
        networkInfo: SimpleNetworkInfo(),
      );
      
      final scannerBloc = ScannerBloc(
        checkTicketStatus: CheckTicketStatus(repository),
        validateTicketQR: ValidateTicketQR(repository),
        updateTicketRunnerData: UpdateTicketRunnerData(repository),
      );

      final expectedStates = [
        isA<CheckingTicketStatus>(),
        predicate<ScannerError>((s) => s.message.contains('Token de autenticación inválido')),
      ];

      expectLater(scannerBloc.stream, emitsInOrder(expectedStates));

      scannerBloc.add(const CheckTicketStatusEvent('ANY_CODE'));
    });
  });
}
