import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/attendee_status_summary.dart';
import '../repositories/event_repository.dart';

class GetAttendeeStatusSummary {
  final EventRepository repository;

  GetAttendeeStatusSummary(this.repository);

  Future<Either<Failure, AttendeeStatusSummary>> execute(String eventId) async {
    return await repository.getAttendeeStatusSummary(eventId);
  }
}
