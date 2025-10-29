import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/validation_result.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/ticket_remote_data_source.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDataSource remoteDataSource;

  TicketRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ValidationResult>> checkTicketStatus(
    String validationCode,
  ) async {
    try {
      final result = await remoteDataSource.checkTicketStatus(validationCode);
      return Right(_mapToEntity(result));
    } on ServerException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(ValidationFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ValidationResult>> validateTicketQR(
    String validationCode,
  ) async {
    try {
      final result = await remoteDataSource.validateTicketQR(validationCode);
      return Right(_mapToEntity(result));
    } on ServerException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(ValidationFailure('Error inesperado: $e'));
    }
  }

  ValidationResult _mapToEntity(dynamic model) {
    return ValidationResult(
      isValid: model.isValid,
      message: model.message,
      validationCode: model.validationCode,
      status: ValidationStatusExtension.fromString(model.status),
      eventName: model.eventName,
      ticketName: model.ticketName,
      participantName: model.participantName,
      participantEmail: model.participantEmail,
      validatedAt: model.validatedAt,
      validatedBy: model.validatedBy,
    );
  }
}
