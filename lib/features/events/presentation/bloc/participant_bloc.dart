import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/participant.dart';
import '../../domain/usecases/get_event_participants_detailed.dart';
import '../../domain/usecases/search_participants.dart';
import '../../domain/usecases/synchronize_participants.dart';
import '../../domain/usecases/clear_local_cache.dart';

// Events
abstract class ParticipantEvent extends Equatable {
  const ParticipantEvent();

  @override
  List<Object> get props => [];
}

class FetchParticipantsEvent extends ParticipantEvent {
  final String eventId;
  final String token;
  final int page;
  final int pageSize;
  final bool isLoadMore;

  const FetchParticipantsEvent({
    required this.eventId,
    required this.token,
    this.page = 1,
    this.pageSize = 10,
    this.isLoadMore = false,
  });

  @override
  List<Object> get props => [eventId, token, page, pageSize, isLoadMore];
}

class SearchParticipantsEvent extends ParticipantEvent {
  final String eventId;
  final String query;

  const SearchParticipantsEvent({required this.eventId, required this.query});

  @override
  List<Object> get props => [eventId, query];
}

class SynchronizeParticipantsEvent extends ParticipantEvent {
  final String eventId;
  final String token;

  const SynchronizeParticipantsEvent({
    required this.eventId,
    required this.token,
  });

  @override
  List<Object> get props => [eventId, token];
}

class ClearLocalCacheEvent extends ParticipantEvent {
  final String eventId;

  const ClearLocalCacheEvent({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

// States
abstract class ParticipantState extends Equatable {
  const ParticipantState();

  @override
  List<Object> get props => [];
}

class ParticipantInitial extends ParticipantState {
  const ParticipantInitial();
}

class ParticipantLoading extends ParticipantState {
  const ParticipantLoading();
}

class ParticipantLoaded extends ParticipantState {
  final List<Participant> participants;
  final Map<String, dynamic> pagination;
  final bool isLoadingMore;

  const ParticipantLoaded({
    required this.participants,
    required this.pagination,
    this.isLoadingMore = false,
  });

  @override
  List<Object> get props => [participants, pagination, isLoadingMore];

  ParticipantLoaded copyWith({
    List<Participant>? participants,
    Map<String, dynamic>? pagination,
    bool? isLoadingMore,
  }) {
    return ParticipantLoaded(
      participants: participants ?? this.participants,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ParticipantError extends ParticipantState {
  final String message;

  const ParticipantError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class ParticipantBloc extends Bloc<ParticipantEvent, ParticipantState> {
  final GetEventParticipantsDetailed getEventParticipantsDetailed;
  final SearchParticipants searchParticipants;
  final SynchronizeParticipants synchronizeParticipants;
  final ClearLocalCache clearLocalCache;

  ParticipantBloc({
    required this.getEventParticipantsDetailed,
    required this.searchParticipants,
    required this.synchronizeParticipants,
    required this.clearLocalCache,
  }) : super(const ParticipantInitial()) {
    on<FetchParticipantsEvent>(_onFetchParticipants);
    on<SearchParticipantsEvent>(_onSearchParticipants);
    on<SynchronizeParticipantsEvent>(_onSynchronizeParticipants);
    on<ClearLocalCacheEvent>(_onClearLocalCache);
  }

  Future<void> _onFetchParticipants(
    FetchParticipantsEvent event,
    Emitter<ParticipantState> emit,
  ) async {
    // Si es cargar más (load more), emitir estado con isLoadingMore = true
    if (event.isLoadMore && state is ParticipantLoaded) {
      final currentState = state as ParticipantLoaded;
      emit(currentState.copyWith(isLoadingMore: true));
    } else {
      // Primera carga o recarga
      emit(const ParticipantLoading());
    }

    final result = await getEventParticipantsDetailed(
      event.eventId,
      event.token,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold((failure) => emit(ParticipantError(message: failure.message)), (
      data,
    ) {
      final newParticipants = (data['data'] ?? []) as List<Participant>;
      final pagination = data['pagination'] ?? {};

      if (event.isLoadMore && state is ParticipantLoaded) {
        // Append: agregar nuevos participantes a los existentes
        final currentState = state as ParticipantLoaded;
        final allParticipants = [
          ...currentState.participants,
          ...newParticipants,
        ];
        emit(
          ParticipantLoaded(
            participants: allParticipants,
            pagination: pagination,
            isLoadingMore: false,
          ),
        );
      } else {
        // Replace: primera carga o recarga
        emit(
          ParticipantLoaded(
            participants: newParticipants,
            pagination: pagination,
            isLoadingMore: false,
          ),
        );
      }
    });
  }

  Future<void> _onSearchParticipants(
    SearchParticipantsEvent event,
    Emitter<ParticipantState> emit,
  ) async {
    emit(const ParticipantLoading());

    final result = await searchParticipants(event.eventId, event.query);

    result.fold((failure) => emit(ParticipantError(message: failure.message)), (
      searchResults,
    ) {
      final participants = searchResults.cast<Participant>().toList();

      emit(
        ParticipantLoaded(
          participants: participants,
          pagination: {
            'totalRecords': participants.length,
            'totalPages': 1,
            'currentPage': 1,
            'pageSize': participants.length,
          },
          isLoadingMore: false,
        ),
      );
    });
  }

  Future<void> _onSynchronizeParticipants(
    SynchronizeParticipantsEvent event,
    Emitter<ParticipantState> emit,
  ) async {
    final currentState = state;
    if (currentState is ParticipantLoaded) {
      emit(currentState.copyWith(isLoadingMore: true));
    }

    final result = await synchronizeParticipants(event.eventId, event.token);

    result.fold(
      (failure) {
        if (currentState is ParticipantLoaded) {
          emit(currentState.copyWith(isLoadingMore: false));
        }
        emit(
          ParticipantError(message: 'Error sincronizando: ${failure.message}'),
        );
      },
      (_) {
        // Después de sincronizar, recargar participantes
        add(
          FetchParticipantsEvent(
            eventId: event.eventId,
            token: event.token,
            page: 1,
            pageSize: 10,
            isLoadMore: false,
          ),
        );
      },
    );
  }

  Future<void> _onClearLocalCache(
    ClearLocalCacheEvent event,
    Emitter<ParticipantState> emit,
  ) async {
    try {
      emit(const ParticipantLoading());
      final result = await clearLocalCache(event.eventId);

      result.fold(
        (failure) => emit(
          ParticipantError(
            message: 'Error al limpiar caché: ${failure.message}',
          ),
        ),
        (_) => emit(const ParticipantInitial()),
      );
    } catch (e) {
      emit(ParticipantError(message: 'Error inesperado: ${e.toString()}'));
    }
  }
}
