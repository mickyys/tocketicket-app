import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/participant.dart';
import '../../domain/usecases/get_event_participants_detailed.dart';
import '../../domain/usecases/search_participants.dart';
import '../../domain/usecases/change_participant.dart';

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
  final String token;
  final String query;

  const SearchParticipantsEvent({
    required this.eventId,
    required this.token,
    required this.query,
  });

  @override
  List<Object> get props => [eventId, token, query];
}

class ChangeParticipantEvent extends ParticipantEvent {
  final String orderId;
  final String participantId;
  final String token;
  final Map<String, dynamic> data;

  const ChangeParticipantEvent({
    required this.orderId,
    required this.participantId,
    required this.token,
    required this.data,
  });

  @override
  List<Object> get props => [orderId, participantId, token, data];
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

class ChangeParticipantLoading extends ParticipantState {
  const ChangeParticipantLoading();
}

class ChangeParticipantSuccess extends ParticipantState {
  const ChangeParticipantSuccess();
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
  final ChangeParticipant changeParticipant;

  ParticipantBloc({
    required this.getEventParticipantsDetailed,
    required this.searchParticipants,
    required this.changeParticipant,
  }) : super(const ParticipantInitial()) {
    on<FetchParticipantsEvent>(_onFetchParticipants);
    on<SearchParticipantsEvent>(_onSearchParticipants);
    on<ChangeParticipantEvent>(_onChangeParticipant);
  }

  Future<void> _onChangeParticipant(
    ChangeParticipantEvent event,
    Emitter<ParticipantState> emit,
  ) async {
    final previousState = state;
    emit(const ChangeParticipantLoading());

    final result = await changeParticipant.execute(
      event.orderId,
      event.participantId,
      event.token,
      event.data,
    );

    result.fold((failure) {
      emit(ParticipantError(message: failure.message));
      if (previousState is ParticipantLoaded) {
        emit(previousState);
      }
    }, (success) {
      emit(const ChangeParticipantSuccess());
      if (previousState is ParticipantLoaded) {
        emit(previousState);
      }
    });
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

    final result = await searchParticipants(
      event.eventId,
      event.token,
      event.query,
    );

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
}
