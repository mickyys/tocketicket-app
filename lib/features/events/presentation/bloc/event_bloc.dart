import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/synchronize_event_attendees.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final SynchronizeEventAttendees synchronizeEventAttendees;
  final GetEvents getEvents;

  EventBloc({required this.synchronizeEventAttendees, required this.getEvents})
    : super(EventInitial()) {
    on<FetchEvents>(_onFetchEvents);
    on<SynchronizeEventAttendeesEvent>(_onSynchronizeEventAttendees);
  }

  Future<void> _onFetchEvents(
    FetchEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final result = await getEvents(NoParams());
      result.fold(
        (failure) {
          String errorMessage = 'Error al cargar eventos';
          if (failure is ServerFailure) {
            errorMessage = 'Error del servidor. Intenta de nuevo.';
          } else if (failure is NetworkFailure) {
            errorMessage = 'Error de conexión. Verifica tu internet.';
          } else if (failure is ValidationFailure) {
            errorMessage = failure.message;
          }
          emit(EventError(errorMessage));
        },
        (events) {
          emit(EventLoaded(events));
        },
      );
    } catch (e) {
      emit(EventError('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onSynchronizeEventAttendees(
    SynchronizeEventAttendeesEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(SyncInProgress(event.eventId));
    try {
      final result = await synchronizeEventAttendees(event.eventId);
      result.fold((failure) {
        String errorMessage = 'Error al sincronizar asistentes';
        if (failure is ServerFailure) {
          errorMessage = 'Error del servidor al sincronizar';
        } else if (failure is NetworkFailure) {
          errorMessage = 'Error de conexión durante la sincronización';
        } else if (failure is ValidationFailure) {
          errorMessage = failure.message;
        }
        emit(SyncFailure(event.eventId, errorMessage));
      }, (_) => emit(SyncSuccess(event.eventId)));
    } catch (e) {
      emit(SyncFailure(event.eventId, 'Error inesperado: ${e.toString()}'));
    }
  }
}
