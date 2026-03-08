import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/participants_repository.dart';

class GetEventParticipantsDetailed {
  final ParticipantsRepository repository;

  GetEventParticipantsDetailed({required this.repository});

  Future<Either<Failure, Map<String, dynamic>>> call(
    String eventId,
    String token, {
    int page = 1,
    int pageSize = 10,
  }) async {
    return await repository.getEventParticipantsDetailed(
      eventId,
      token,
      page: page,
      pageSize: pageSize,
    );
  }
}
