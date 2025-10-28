import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/event_repository.dart';

class SynchronizeEventAttendees implements UseCase<Unit, String> {
  final EventRepository repository;

  SynchronizeEventAttendees(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String params) async {
    return await repository.synchronizeEventAttendees(params);
  }
}
