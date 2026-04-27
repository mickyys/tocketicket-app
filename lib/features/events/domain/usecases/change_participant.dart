import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/participants_repository.dart';

class ChangeParticipant {
  final ParticipantsRepository repository;

  ChangeParticipant(this.repository);

  Future<Either<Failure, void>> execute(
    String orderId,
    String participantId,
    String token,
    Map<String, dynamic> data,
  ) async {
    return await repository.changeParticipant(orderId, participantId, token, data);
  }
}
