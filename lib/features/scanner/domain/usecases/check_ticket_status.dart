import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/validation_result.dart';
import '../repositories/ticket_repository.dart';

class CheckTicketStatus implements UseCase<ValidationResult, String> {
  final TicketRepository repository;

  CheckTicketStatus(this.repository);

  @override
  Future<Either<Failure, ValidationResult>> call(String validationCode) async {
    return await repository.checkTicketStatus(validationCode);
  }
}
