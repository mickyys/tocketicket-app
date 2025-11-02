import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../services/event_service.dart';
import '../../features/events/data/repositories/event_repository_impl.dart';
import '../../features/events/domain/repositories/event_repository.dart';
import '../../features/events/domain/usecases/get_events.dart';
import '../../features/events/domain/usecases/synchronize_event_attendees.dart';
import '../../features/scanner/data/datasources/ticket_remote_data_source.dart';
import '../../features/scanner/data/repositories/ticket_repository_impl.dart';
import '../../features/scanner/domain/repositories/ticket_repository.dart';
import '../../features/scanner/domain/usecases/check_ticket_status.dart';
import '../../features/scanner/domain/usecases/validate_ticket_qr.dart';
import '../storage/database_helper.dart';

class DependencyInjection {
  static List<RepositoryProvider> get repositoryProviders => [
    // HTTP Client
    RepositoryProvider<http.Client>(create: (_) => http.Client()),

    // Database Helper
    RepositoryProvider<DatabaseHelper>(create: (_) => DatabaseHelper.instance),

    // Services
    RepositoryProvider<EventService>(
      create: (context) => EventService(client: context.read<http.Client>()),
    ),

    // Data Sources
    RepositoryProvider<TicketRemoteDataSource>(
      create: (context) =>
          TicketRemoteDataSourceImpl(client: context.read<http.Client>()),
    ),

    // Repositories
    RepositoryProvider<EventRepository>(
      create: (context) => EventRepositoryImpl(
        eventService: context.read<EventService>(),
        databaseHelper: context.read<DatabaseHelper>(),
      ),
    ),

    RepositoryProvider<TicketRepository>(
      create: (context) => TicketRepositoryImpl(
        remoteDataSource: context.read<TicketRemoteDataSource>(),
      ),
    ),

    // Use Cases
    RepositoryProvider<GetEvents>(
      create: (context) => GetEvents(context.read<EventRepository>()),
    ),

    RepositoryProvider<SynchronizeEventAttendees>(
      create: (context) =>
          SynchronizeEventAttendees(context.read<EventRepository>()),
    ),

    RepositoryProvider<CheckTicketStatus>(
      create: (context) => CheckTicketStatus(context.read<TicketRepository>()),
    ),

    RepositoryProvider<ValidateTicketQR>(
      create: (context) => ValidateTicketQR(context.read<TicketRepository>()),
    ),
  ];
}
