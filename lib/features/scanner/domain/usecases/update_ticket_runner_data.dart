import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/validation_result.dart';
import '../repositories/ticket_repository.dart';

class UpdateTicketRunnerData
    implements UseCase<ValidationResult, UpdateTicketRunnerDataParams> {
  final TicketRepository repository;

  UpdateTicketRunnerData(this.repository);

  @override
  Future<Either<Failure, ValidationResult>> call(
    UpdateTicketRunnerDataParams params,
  ) async {
    return await repository.updateTicketRunnerData(
      params.validationCode,
      params.runnerNumber,
      params.chipId,
    );
  }
}

class UpdateTicketRunnerDataParams extends Equatable {
  final String validationCode;
  final String runnerNumber;
  final String chipId;

  const UpdateTicketRunnerDataParams({
    required this.validationCode,
    required this.runnerNumber,
    required this.chipId,
  });

  @override
  List<Object> get props => [validationCode, runnerNumber, chipId];
}
