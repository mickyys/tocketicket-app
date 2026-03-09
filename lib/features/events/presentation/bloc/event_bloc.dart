import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/synchronize_event_attendees.dart';
import '../../domain/usecases/synchronize_participants.dart';
import '../../domain/usecases/get_attendee_status_summary.dart';
import '../../domain/entities/attendee_status_summary.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final SynchronizeEventAttendees synchronizeEventAttendees;
  final GetEvents getEvents;
  final SynchronizeParticipants synchronizeParticipants;
  final GetAttendeeStatusSummary getAttendeeStatusSummary;

  EventBloc({
    required this.synchronizeEventAttendees,
    required this.getEvents,
    required this.synchronizeParticipants,
    required this.getAttendeeStatusSummary,
  }) : super(EventInitial()) {
    on<FetchEvents>(_onFetchEvents);
    on<SynchronizeEventAttendeesEvent>(_onSynchronizeEventAttendees);
    on<GetAttendeeStatusSummaryEvent>(_onGetAttendeeStatusSummary);
  }

  Future<void> _onFetchEvents(
    FetchEvents event,
    Emitter<EventState> emit,
  ) async {
    print('EventBloc: FetchEvents triggered');
    emit(EventLoading());
    try {
      final result = await getEvents(NoParams());
      result.fold(
        (failure) {
          print('EventBloc: FetchEvents failed with failure: $failure');
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
          print(
            'EventBloc: FetchEvents success, loaded ${events.length} events',
          );
          emit(EventLoaded(events));

          // Iniciar sincronización en background para cada evento
          _syncParticipantsInBackground(events);
        },
      );
    } catch (e, stacktrace) {
      print('EventBloc: Unexpected error in FetchEvents: $e');
      print('Stacktrace: $stacktrace');
      emit(EventError('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _syncParticipantsInBackground(List<Event> events) async {
    final token = await AuthService.getAccessToken() ?? '';
    if (token.isEmpty) return;

    for (final event in events) {
      try {
        await synchronizeParticipants(event.id, token);
      } catch (e) {
        // Ignorar errores en sincronización de background
        // No queremos que una falla en un evento afecte los otros
      }
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

  Future<void> _onGetAttendeeStatusSummary(
    GetAttendeeStatusSummaryEvent event,
    Emitter<EventState> emit,
  ) async {
    print(
      '[EventBloc#$hashCode] GetAttendeeStatusSummary: iniciando request para evento ${event.eventId}',
    );
    emit(AttendeeStatusSummaryLoading(event.eventId));
    try {
      final result = await getAttendeeStatusSummary.execute(event.eventId);
      result.fold(
        (failure) {
          print(
            '[EventBloc#$hashCode] GetAttendeeStatusSummary: ERROR → $failure',
          );
          emit(
            AttendeeStatusSummaryError(
              event.eventId,
              'Error al cargar resumen',
            ),
          );
        },
        (summary) {
          print(
            '[EventBloc#$hashCode] GetAttendeeStatusSummary: OK → confirmed=${summary.confirmed} unconfirmed=${summary.unconfirmed} total=${summary.total}',
          );
          emit(AttendeeStatusSummaryLoaded(event.eventId, summary));
        },
      );
    } catch (e) {
      print('[EventBloc#$hashCode] GetAttendeeStatusSummary: EXCEPCIÓN → $e');
      emit(AttendeeStatusSummaryError(event.eventId, e.toString()));
    }
  }
}
