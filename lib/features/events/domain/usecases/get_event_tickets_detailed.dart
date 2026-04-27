import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/participants_repository.dart';

class GetEventTicketsDetailed {
  final ParticipantsRepository repository;

  GetEventTicketsDetailed(this.repository);

  Future<Either<Failure, List<dynamic>>> execute(
    String eventId,
    String token,
    bool isAdmin,
  ) async {
    return await repository.getEventTickets(eventId, token, isAdmin);
  }
}
