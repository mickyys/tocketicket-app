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
}
