import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/participants_repository.dart';
import '../datasources/participants_remote_data_source.dart';
import '../models/participant_model.dart';

class ParticipantsRepositoryImpl implements ParticipantsRepository {
  final ParticipantsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ParticipantsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getEventParticipantsDetailed(
    String eventId,
    String token, {
    int page = 1,
    int pageSize = 10,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(
        ServerFailure('Se requiere conexión a internet para esta operación.'),
      );
    }

    try {
      // Cargar siempre desde remoto
      final result = await remoteDataSource.getEventParticipantsDetailed(
        eventId,
        token,
        page: page,
        pageSize: pageSize,
      );

      // Convertir modelos a entidades
      final List<dynamic> dataList = result['data'] ?? [];
      final participantModels =
          dataList
              .map((p) => ParticipantModel.fromJson(p as Map<String, dynamic>))
              .toList();

      return Right({
        'data': participantModels.map((p) => p.toEntity()).toList(),
        'pagination': result['pagination'] ?? {},
      });
    } catch (e) {
      return Left(ServerFailure('Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> searchParticipants(
    String eventId,
    String token,
    String query,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(
        ServerFailure('Se requiere conexión a internet para esta operación.'),
      );
    }

    try {
      final results = await remoteDataSource.searchParticipants(
        eventId,
        token,
        query,
      );
      final participantModels =
          results
              .map((p) => ParticipantModel.fromJson(p as Map<String, dynamic>))
              .toList();
      return Right(participantModels.map((p) => p.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure('Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> changeParticipant(
    String orderId,
    String participantId,
    String token,
    Map<String, dynamic> data,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(
        ServerFailure('Se requiere conexión a internet para esta operación.'),
      );
    }

    try {
      await remoteDataSource.changeParticipant(orderId, participantId, token, data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getEventCategories(
    String eventId,
    String token,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(
        ServerFailure('Se requiere conexión a internet para esta operación.'),
      );
    }

    try {
      final results = await remoteDataSource.getEventCategories(eventId, token);
      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getEventCategoriesByTicket(
    String eventId,
    String ticketId,
    String token,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(
        ServerFailure('Se requiere conexión a internet para esta operación.'),
      );
    }

    try {
      final results = await remoteDataSource.getEventCategoriesByTicket(eventId, ticketId, token);
      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getEventTickets(
    String eventId,
    String token,
    bool isAdmin,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(
        ServerFailure('Se requiere conexión a internet para esta operación.'),
      );
    }

    try {
      final results = await remoteDataSource.getEventTickets(
        eventId,
        token,
        isAdmin,
      );
      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
