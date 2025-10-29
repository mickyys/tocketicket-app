import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/database_helper.dart';
import '../../../../core/services/event_service.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventService eventService;
  final DatabaseHelper databaseHelper;

  EventRepositoryImpl({
    required this.eventService,
    required this.databaseHelper,
  });

  @override
  Future<Either<Failure, Unit>> synchronizeEventAttendees(
    String eventId,
  ) async {
    try {
      final remoteAttendees = await eventService.fetchAllAttendees(eventId);
      final attendeeMaps = remoteAttendees
          .map((attendee) => attendee.toMap())
          .toList();
      await databaseHelper.syncAttendees(eventId, attendeeMaps);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getEvents() async {
    try {
      final remoteEvents = await eventService.getEvents();
      return Right(remoteEvents);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
