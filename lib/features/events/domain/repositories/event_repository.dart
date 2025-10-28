import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/attendee.dart';

abstract class EventRepository {
  Future<Either<Failure, Unit>> synchronizeEventAttendees(String eventId);
  Future<Either<Failure, List<Event>>> getEvents();
}
