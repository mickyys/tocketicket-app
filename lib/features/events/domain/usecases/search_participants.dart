import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/participants_repository.dart';

class SearchParticipants {
  final ParticipantsRepository repository;

  SearchParticipants({required this.repository});

  Future<Either<Failure, List<dynamic>>> call(String eventId, String query) {
    return repository.searchParticipants(eventId, query);
  }
}
