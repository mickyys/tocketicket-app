import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class ParticipantsRepository {
  Future<Either<Failure, Map<String, dynamic>>> getEventParticipantsDetailed(
    String eventId,
    String token, {
    int page = 1,
    int pageSize = 10,
  });

  Future<Either<Failure, List<dynamic>>> searchParticipants(
    String eventId,
    String token,
    String query,
  );
}
