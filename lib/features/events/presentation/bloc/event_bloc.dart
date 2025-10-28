import 'package:bloc/bloc.dart';
import 'package.equatable/equatable.dart';
import '../../../../core/usecases/no_params.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/synchronize_event_attendees.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final SynchronizeEventAttendees synchronizeEventAttendees;
  final GetEvents getEvents;

  EventBloc({
    required this.synchronizeEventAttendees,
    required this.getEvents,
  }) : super(EventInitial()) {
    on<FetchEvents>(_onFetchEvents);
    on<SynchronizeEventAttendeesEvent>(_onSynchronizeEventAttendees);
  }

  Future<void> _onFetchEvents(
    FetchEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    final result = await getEvents(NoParams());
    result.fold(
      (failure) => emit(EventError('Failed to fetch events')),
      (events) => emit(EventLoaded(events)),
    );
  }

  Future<void> _onSynchronizeEventAttendees(
    SynchronizeEventAttendeesEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(SyncInProgress(event.eventId));
    final result = await synchronizeEventAttendees(event.eventId);
    result.fold(
      (failure) => emit(SyncFailure(event.eventId, 'Failed to sync attendees')),
      (_) => emit(SyncSuccess(event.eventId)),
    );
  }
}
