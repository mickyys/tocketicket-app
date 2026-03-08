import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object> get props => [];

  String get message => 'An error occurred';
}

// General failures
class ServerFailure extends Failure {
  final String? errorMessage;

  const ServerFailure({this.errorMessage});

  @override
  String get message => errorMessage ?? 'Server error occurred';

  @override
  List<Object> get props => [errorMessage ?? ''];
}

class CacheFailure extends Failure {
  @override
  String get message => 'Cache error occurred';
}

class NetworkFailure extends Failure {
  @override
  String get message => 'Network error occurred';
}

class ValidationFailure extends Failure {
  final String errorMessage;

  const ValidationFailure(this.errorMessage);

  @override
  String get message => errorMessage;

  @override
  List<Object> get props => [errorMessage];
}
