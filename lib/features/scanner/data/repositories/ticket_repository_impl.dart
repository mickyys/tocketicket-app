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
      eventName: model.eventName,
      participantName: model.participantName,
      participantDocument: model.participantDocument ?? model.participantRut,
      documentType:
          model.documentType ?? 'rut', // Default a RUT si no está especificado
      participantStatus:
          model.participantStatus ?? 'active', // Valor por defecto
      ticketCorrelative: model.ticketCorrelative ?? 0, // Valor por defecto
      ticketStatus: model.ticketStatus,
      validatedAt: model.validatedAt,
      categoryName: model.categoryName,
      ticketName: model.ticketName,
      purchaseDate: model.purchaseDate,
      validationCode: model.validationCode,
    );
  }
}
