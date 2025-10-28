part of 'event_bloc.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object> get props => [];
}

class FetchEvents extends EventEvent {}

class SynchronizeEventAttendeesEvent extends EventEvent {
  final String eventId;

  const SynchronizeEventAttendeesEvent(this.eventId);

  @override
  List<Object> get props => [eventId];
}
