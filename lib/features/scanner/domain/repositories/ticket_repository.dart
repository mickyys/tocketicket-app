import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/validation_result.dart';

abstract class TicketRepository {
  /// Consulta el estado de un ticket usando el código de validación
  /// Endpoint: GET /tickets/status/:validationCode
  Future<Either<Failure, ValidationResult>> checkTicketStatus(
    String validationCode,
  );

  /// Valida un ticket QR y lo marca como usado
  /// Endpoint: POST /tickets/validate-qr
  /// Body: {"validationCode": "code"}
  Future<Either<Failure, ValidationResult>> validateTicketQR(
    String validationCode,
  );

  /// Actualiza los datos del corredor (número y chip) de un ticket
  /// Endpoint: POST /tickets/validate-qr
  /// Body: {"validationCode": "code", "runnerNumber": "123", "chipId": "CHIP123"}
  Future<Either<Failure, ValidationResult>> updateTicketRunnerData(
    String validationCode,
    String runnerNumber,
    String chipId,
  );
}
