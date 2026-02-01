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

  @override
  Future<Either<Failure, ValidationResult>> updateTicketRunnerData(
    String validationCode,
    String runnerNumber,
    String chipId,
  ) async {
    try {
      final result = await remoteDataSource.updateTicketRunnerData(
        validationCode,
        runnerNumber,
        chipId,
      );
      return Right(_mapToEntity(result));
    } on ServerException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(ValidationFailure('Error inesperado: $e'));
    }
  }

  ValidationResult _mapToEntity(dynamic model) {
    return ValidationResult(
      eventName: model.eventName,
      participantName: model.participantName,
      ticketStatus: model.ticketStatus,
      categoryName: model.categoryName,
      ticketName: model.ticketName,
      ticketCorrelative: model.ticketCorrelative,
      participantStatus: model.participantStatus,
      participantDocumentType: model.participantDocumentType,
      participantDocumentNumber: model.participantDocumentNumber,
      validatedAt: model.validatedAt,
      purchaseDate: model.purchaseDate,
      runnerNumber: model.runnerNumber,
      chipId: model.chipId,
      validationCode: model.validationCode,
      isValid: model.isValid ?? (model.ticketStatus == 'valid'),
    );
  }
}
