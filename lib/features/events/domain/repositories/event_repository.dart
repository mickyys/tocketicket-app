import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';
import '../entities/attendee_status_summary.dart';

abstract class EventRepository {
  Future<Either<Failure, Unit>> synchronizeEventAttendees(String eventId);
  Future<Either<Failure, List<Event>>> getEvents();
  Future<Either<Failure, AttendeeStatusSummary>> getAttendeeStatusSummary(
    String eventId,
  );
}
