import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/participants_repository.dart';

class GetEventCategories {
  final ParticipantsRepository repository;

  GetEventCategories(this.repository);

  Future<Either<Failure, List<dynamic>>> execute(
    String eventId,
    String token,
  ) async {
    return await repository.getEventCategories(eventId, token);
  }
}

class GetEventCategoriesByTicket {
  final ParticipantsRepository repository;

  GetEventCategoriesByTicket(this.repository);

  Future<Either<Failure, List<dynamic>>> execute(
    String eventId,
    String ticketId,
    String token,
  ) async {
    return await repository.getEventCategoriesByTicket(eventId, ticketId, token);
  }
}
