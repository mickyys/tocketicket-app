import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:tocke/core/errors/failures.dart';
import 'package:tocke/features/events/domain/usecases/search_participants.dart';
import 'package:tocke/features/events/domain/repositories/participants_repository.dart';

class MockParticipantsRepository implements ParticipantsRepository {
  List<dynamic> result = [];
  bool shouldFail = false;

  @override
  Future<Either<Failure, List<dynamic>>> searchParticipants(
    String eventId, String token, String query) async {
    if (shouldFail) {
      return const Left(ServerFailure('Error de red'));
    }
    return Right(result);
  }

  // Métodos no usados
  @override
  Future<Either<Failure, Map<String, dynamic>>> getEventParticipantsDetailed(
    String eventId, String token, {int page = 1, int pageSize = 10}) => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> changeParticipant(
    String orderId, String participantId, String token, Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<Either<Failure, List<dynamic>>> getEventCategories(String eventId, String token) => throw UnimplementedError();
  @override
  Future<Either<Failure, List<dynamic>>> getEventCategoriesByTicket(String eventId, String ticketId, String token) => throw UnimplementedError();
  @override
  Future<Either<Failure, List<dynamic>>> getEventTickets(String eventId, String token, bool isAdmin) => throw UnimplementedError();
}

void main() {
  late SearchParticipants useCase;
  late MockParticipantsRepository mockRepository;

  setUp(() {
    mockRepository = MockParticipantsRepository();
    useCase = SearchParticipants(repository: mockRepository);
  });

  const tEventId = '123';
  const tToken = 'token';
  const tQuery = 'Juan';

  test('Debe retornar una lista de participantes cuando la búsqueda es exitosa', () async {
    // arrange
    final tResult = [{'name': 'Juan Perez'}, {'name': 'Juan Lopez'}];
    mockRepository.result = tResult;

    // act
    final result = await useCase.call(tEventId, tToken, tQuery);

    // assert
    expect(result, Right(tResult));
  });

  test('Debe retornar un error cuando la búsqueda falla', () async {
    // arrange
    mockRepository.shouldFail = true;

    // act
    final result = await useCase.call(tEventId, tToken, tQuery);

    // assert
    expect(result, isA<Left<Failure, List<dynamic>>>());
  });
}
