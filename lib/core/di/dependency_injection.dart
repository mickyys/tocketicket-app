import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../database/participant_database.dart';
import '../../config/app_config.dart';
import '../../features/events/data/repositories/event_repository_impl.dart';
import '../../features/events/domain/repositories/event_repository.dart';
import '../../features/events/domain/usecases/get_events.dart';
import '../../features/events/domain/usecases/synchronize_event_attendees.dart';
import '../../features/events/domain/usecases/get_event_participants_detailed.dart';
import '../../features/events/domain/usecases/search_participants.dart';
import '../../features/events/domain/usecases/synchronize_participants.dart';
import '../../features/events/domain/usecases/get_attendee_status_summary.dart';
import '../../features/events/domain/usecases/clear_local_cache.dart';
import '../../features/events/data/datasources/participants_remote_data_source.dart';
import '../../features/events/data/datasources/participants_local_data_source.dart';
import '../../features/events/data/repositories/participants_repository_impl.dart';
import '../../features/events/domain/repositories/participants_repository.dart';
import '../../features/scanner/data/datasources/ticket_remote_data_source.dart';
import '../../features/scanner/data/repositories/ticket_repository_impl.dart';
import '../../features/scanner/domain/repositories/ticket_repository.dart';
import '../../features/scanner/domain/usecases/check_ticket_status.dart';
import '../../features/scanner/domain/usecases/validate_ticket_qr.dart';
import '../../features/scanner/domain/usecases/update_ticket_runner_data.dart';
import '../storage/database_helper.dart';

class DependencyInjection {
  static List<RepositoryProvider> get repositoryProviders => [
    // HTTP Client
    RepositoryProvider<http.Client>(
      create: (_) {
        // Usar cliente HTTP estándar
        final client = http.Client();

        // Configurar AuthService con el cliente
        AuthService.setHttpClient(client);

        if (kDebugMode) {
          debugPrint(
            '🚀 DI: Cliente HTTP estándar configurado para todos los servicios',
          );
        }

        return client;
      },
    ),

    // Dio Client
    RepositoryProvider<Dio>(
      create: (_) {
        final dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
        return dio;
      },
    ),

    // Database Helper
    RepositoryProvider<DatabaseHelper>(create: (_) => DatabaseHelper.instance),

    // Services
    RepositoryProvider<EventService>(
      create: (context) => EventService(client: context.read<http.Client>()),
    ),

    // Data Sources
    RepositoryProvider<TicketRemoteDataSource>(
      create:
          (context) =>
              TicketRemoteDataSourceImpl(client: context.read<http.Client>()),
    ),

    RepositoryProvider<ParticipantsRemoteDataSource>(
      create:
          (context) => ParticipantsRemoteDataSourceImpl(
            dio: context.read<Dio>(),
            baseUrl: AppConfig.baseUrl,
          ),
    ),

    RepositoryProvider<ParticipantsLocalDataSource>(
      create:
          (context) =>
              ParticipantsLocalDataSourceImpl(database: ParticipantDatabase()),
    ),

    // Repositories
    RepositoryProvider<EventRepository>(
      create:
          (context) => EventRepositoryImpl(
            eventService: context.read<EventService>(),
            databaseHelper: context.read<DatabaseHelper>(),
          ),
    ),

    RepositoryProvider<TicketRepository>(
      create:
          (context) => TicketRepositoryImpl(
            remoteDataSource: context.read<TicketRemoteDataSource>(),
            localDataSource: context.read<ParticipantsLocalDataSource>(),
          ),
    ),

    RepositoryProvider<ParticipantsRepository>(
      create:
          (context) => ParticipantsRepositoryImpl(
            remoteDataSource: context.read<ParticipantsRemoteDataSource>(),
            localDataSource: context.read<ParticipantsLocalDataSource>(),
          ),
    ),

    // Use Cases
    RepositoryProvider<GetEvents>(
      create: (context) => GetEvents(context.read<EventRepository>()),
    ),

    RepositoryProvider<GetAttendeeStatusSummary>(
      create:
          (context) =>
              GetAttendeeStatusSummary(context.read<EventRepository>()),
    ),

    RepositoryProvider<SynchronizeEventAttendees>(
      create:
          (context) =>
              SynchronizeEventAttendees(context.read<EventRepository>()),
    ),

    RepositoryProvider<CheckTicketStatus>(
      create: (context) => CheckTicketStatus(context.read<TicketRepository>()),
    ),

    RepositoryProvider<ValidateTicketQR>(
      create: (context) => ValidateTicketQR(context.read<TicketRepository>()),
    ),

    RepositoryProvider<UpdateTicketRunnerData>(
      create:
          (context) => UpdateTicketRunnerData(context.read<TicketRepository>()),
    ),

    RepositoryProvider<GetEventParticipantsDetailed>(
      create:
          (context) => GetEventParticipantsDetailed(
            repository: context.read<ParticipantsRepository>(),
          ),
    ),

    RepositoryProvider<SearchParticipants>(
      create:
          (context) => SearchParticipants(
            repository: context.read<ParticipantsRepository>(),
          ),
    ),

    RepositoryProvider<SynchronizeParticipants>(
      create:
          (context) => SynchronizeParticipants(
            repository: context.read<ParticipantsRepository>(),
          ),
    ),

    RepositoryProvider<ClearLocalCache>(
      create:
          (context) => ClearLocalCache(
            repository: context.read<ParticipantsRepository>(),
          ),
    ),
  ];
}
