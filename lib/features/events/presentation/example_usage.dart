// Ejemplo de uso del EventBloc actualizado
// Este archivo muestra cómo implementar y usar el EventBloc mejorado

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../core/storage/database_helper.dart';
import '../../../core/services/event_service.dart';
import '../data/repositories/event_repository_impl.dart';
import '../domain/usecases/get_events.dart';
import '../domain/usecases/synchronize_event_attendees.dart';
import 'pages/organizer_events_page.dart';

class EventsAppExample extends StatelessWidget {
  const EventsAppExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tocke Ticket - Eventos',
      home: MultiRepositoryProvider(
        providers: [
          // Configura las dependencias
          RepositoryProvider<EventService>(
            create: (context) => EventService(client: http.Client()),
          ),
          RepositoryProvider<EventRepositoryImpl>(
            create: (context) => EventRepositoryImpl(
              eventService: context.read<EventService>(),
              databaseHelper:
                  DatabaseHelper.instance, // Usando instancia singleton
            ),
          ),
          RepositoryProvider<GetEvents>(
            create: (context) => GetEvents(context.read<EventRepositoryImpl>()),
          ),
          RepositoryProvider<SynchronizeEventAttendees>(
            create: (context) =>
                SynchronizeEventAttendees(context.read<EventRepositoryImpl>()),
          ),
        ],
        child: const OrganizerEventsPage(),
      ),
    );
  }
}
