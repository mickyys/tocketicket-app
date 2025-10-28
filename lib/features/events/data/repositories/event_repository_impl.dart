import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/database_helper.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_data_source.dart';
import '../models/attendee_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;
  final DatabaseHelper databaseHelper;

  EventRepositoryImpl({
    required this.remoteDataSource,
    required this.databaseHelper,
  });

  @override
  Future<Either<Failure, Unit>> synchronizeEventAttendees(String eventId) async {
    try {
      final remoteAttendees = await remoteDataSource.fetchAllAttendees(eventId);
      final attendeeMaps = remoteAttendees.map((attendee) => attendee.toMap()).toList();
      await databaseHelper.syncAttendees(eventId, attendeeMaps);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getEvents() async {
    try {
      final remoteEvents = await remoteDataSource.getEvents();
      return Right(remoteEvents);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
