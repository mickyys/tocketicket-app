import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/participants_repository.dart';
import '../datasources/participants_remote_data_source.dart';
import '../datasources/participants_local_data_source.dart';
import '../models/participant_model.dart';

class ParticipantsRepositoryImpl implements ParticipantsRepository {
  final ParticipantsRemoteDataSource remoteDataSource;
  final ParticipantsLocalDataSource localDataSource;

  ParticipantsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getEventParticipantsDetailed(
    String eventId,
    String token, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      // Primero intentar cargar desde local si es la primera página
      if (page == 1) {
        try {
          final localParticipants = await localDataSource
              .getParticipantsByEvent(eventId);
          if (localParticipants.isNotEmpty) {
            // Retornar desde local pero luego sincronizar en background
            return Right({
              'data': localParticipants.map((p) => p.toEntity()).toList(),
              'pagination': {
                'totalRecords': localParticipants.length,
                'totalPages': (localParticipants.length / pageSize).ceil(),
                'currentPage': page,
                'pageSize': pageSize,
              },
            });
          }
        } catch (e) {
          // Si hay error en local, continuar con remoto
        }
      }

      // Cargar desde remoto
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

      // Cachear en local si es primera página
      if (page == 1) {
        await localDataSource.cacheParticipants(eventId, participantModels);
      }

      return Right({
        'data': participantModels.map((p) => p.toEntity()).toList(),
        'pagination': result['pagination'] ?? {},
      });
    } catch (e) {
      return Left(ServerFailure('Error: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<dynamic>>> searchParticipants(
    String eventId,
    String query,
  ) async {
    try {
      final results = await localDataSource.searchParticipants(eventId, query);
      return Right(results.map((p) => p.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure('Error: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> synchronizeParticipants(
    String eventId,
    String token,
  ) async {
    try {
      final result = await remoteDataSource.getEventParticipantsDetailed(
        eventId,
        token,
        page: 1,
        pageSize: 100, // Cargar hasta 100 en una sincronización
      );

      final List<dynamic> dataList = result['data'] ?? [];
      final participantModels =
          dataList
              .map((p) => ParticipantModel.fromJson(p as Map<String, dynamic>))
              .toList();

      await localDataSource.cacheParticipants(eventId, participantModels);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error sincronizando: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearLocalCache(String eventId) async {
    try {
      await localDataSource.clearParticipantsByEvent(eventId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error limpiando caché: ${e.toString()}'));
    }
  }
}
