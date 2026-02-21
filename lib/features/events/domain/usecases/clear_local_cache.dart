import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/participants_repository.dart';

class ClearLocalCache {
  final ParticipantsRepository repository;

  ClearLocalCache({required this.repository});

  Future<Either<Failure, void>> call(String eventId) async {
    return repository.clearLocalCache(eventId);
  }
}
