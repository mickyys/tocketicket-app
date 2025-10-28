import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> loginWithOtp(String email, String otp);
  Future<Either<Failure, void>> requestOtp(String email);
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, String>> getStoredToken();
  Future<Either<Failure, void>> storeToken(String token);
  Future<Either<Failure, void>> clearToken();
  Future<Either<Failure, bool>> isLoggedIn();
}
