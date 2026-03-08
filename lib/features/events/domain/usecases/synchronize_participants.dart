import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/participants_repository.dart';

class SynchronizeParticipants {
  final ParticipantsRepository repository;

  SynchronizeParticipants({required this.repository});

  Future<Either<Failure, void>> call(String eventId, String token) {
    return repository.synchronizeParticipants(eventId, token);
  }
}
