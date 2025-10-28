part of 'event_bloc.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final List<Event> events;

  const EventLoaded(this.events);

  @override
  List<Object> get props => [events];
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object> get props => [message];
}

class SyncInProgress extends EventState {
  final String eventId;

  const SyncInProgress(this.eventId);

  @override
  List<Object> get props => [eventId];
}

class SyncSuccess extends EventState {
  final String eventId;

  const SyncSuccess(this.eventId);

  @override
  List<Object> get props => [eventId];
}

class SyncFailure extends EventState {
  final String eventId;
  final String message;

  const SyncFailure(this.eventId, this.message);

  @override
  List<Object> get props => [eventId, message];
}
