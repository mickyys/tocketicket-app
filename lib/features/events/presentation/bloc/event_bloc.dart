import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/get_attendee_status_summary.dart';
import '../../domain/entities/attendee_status_summary.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetEvents getEvents;
  final GetAttendeeStatusSummary getAttendeeStatusSummary;

EventBloc({required this.getEvents, required this.getAttendeeStatusSummary})
      : super(EventInitial()) {
    on<FetchEvents>(_onFetchEvents);
    on<SynchronizeEventAttendeesEvent>(_onSynchronizeEventAttendees);
    on<GetAttendeeStatusSummaryEvent>(_onGetAttendeeStatusSummary);
    on<ResetEvents>(_onResetEvents);

    AuthService.onSessionChange.listen((isLoggedIn) {
      if (!isLoggedIn) {
        add(ResetEvents());
      } else {
        add(ResetEvents());
        add(FetchEvents());
      }
    });
  }

  Future<void> _onResetEvents(
    ResetEvents event,
    Emitter<EventState> emit,
  ) async {
    print('EventBloc: ResetEvents triggered, clearing state');
    emit(EventInitial());
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
        },
      );
    } catch (e, stacktrace) {
      print('EventBloc: Unexpected error in FetchEvents: $e');
      print('Stacktrace: $stacktrace');
      emit(EventError('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onSynchronizeEventAttendees(
    SynchronizeEventAttendeesEvent event,
    Emitter<EventState> emit,
  ) async {
    // Ya no sincronizamos localmente, pero podemos refrescar el resumen
    add(GetAttendeeStatusSummaryEvent(event.eventId));
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
