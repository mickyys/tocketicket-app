import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:tocke/features/events/domain/entities/participant.dart';
import 'package:tocke/features/events/domain/entities/event.dart';
import 'package:tocke/features/events/domain/repositories/participants_repository.dart';
import 'package:tocke/features/events/domain/usecases/change_participant.dart';
import 'package:tocke/features/events/domain/usecases/get_event_categories.dart';
import 'package:tocke/features/events/domain/usecases/get_event_tickets_detailed.dart';
import 'package:tocke/features/events/presentation/bloc/participant_bloc.dart';
import 'package:tocke/features/events/presentation/pages/edit_participant_page.dart';
import 'package:tocke/core/errors/failures.dart';
import 'package:tocke/features/events/domain/usecases/get_event_participants_detailed.dart';
import 'package:tocke/features/events/domain/usecases/search_participants.dart';

class MockParticipantsRepository implements ParticipantsRepository {
  String? lastOrderId;
  String? lastParticipantId;
  Map<String, dynamic>? lastData;

  @override
  Future<Either<Failure, void>> changeParticipant(
    String orderId,
    String participantId,
    String token,
    Map<String, dynamic> data,
  ) async {
    lastOrderId = orderId;
    lastParticipantId = participantId;
    lastData = data;
    return const Right(null);
  }

  @override
  Future<Either<Failure, List>> getEventCategories(String eventId, String token) async {
    return const Right([
      {'id': 'cat1', 'name': 'Categoría 1'}
    ]);
  }

  @override
  Future<Either<Failure, List>> getEventCategoriesByTicket(String eventId, String ticketId, String token) async {
    return const Right([
      {'id': 'cat1', 'name': 'Categoría 1'}
    ]);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getEventParticipantsDetailed(
    String eventId,
    String token, {
    int page = 1,
    int pageSize = 10,
  }) async {
    return const Right({'data': [], 'pagination': {}});
  }

  @override
  Future<Either<Failure, List>> getEventTickets(String eventId, String token, bool isAdmin) async {
    return const Right([
      {'id': 'ticket1', 'name': 'Ticket General'}
    ]);
  }

  @override
  Future<Either<Failure, List>> searchParticipants(String eventId, String token, String query) async {
    return const Right([]);
  }
}

void main() {
  late MockParticipantsRepository mockRepository;
  late Participant testParticipant;
  late Event testEvent;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockRepository = MockParticipantsRepository();
    
    // Mock para FlutterSecureStorage
    const MethodChannel channel = MethodChannel('plugins.it_solutions.com.br/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'read') {
        if (methodCall.arguments != null && methodCall.arguments['key'] == 'userData') {
          return '{"role": "admin"}';
        }
        return 'mock_token';
      }
      return null;
    });

    testParticipant = Participant(
      orderId: 'ORDER123',
      eventName: 'Evento Test',
      participantName: 'Juan Perez',
      firstName: 'Juan',
      lastName: 'Perez',
      email: 'juan@test.com',
      participantDocumentNumber: '12345678-9',
      participantDocumentType: 'rut',
      participantStatus: 'confirmed',
      ticketCorrelative: 1,
      ticketStatus: 'active',
      purchaseDate: DateTime.now(),
      validationCode: 'VAL123',
      ticketId: 'ticket1',
      categoryId: 'cat1',
    );

    testEvent = Event(
      id: 'EVENT123',
      name: 'Evento Test',
      description: 'Descripción Test',
      location: 'Santiago',
      address: 'Dirección Test',
      imageUrl: '',
      organizerId: 'ORG123',
      isActive: true,
      isPublic: true,
      ticketsSold: 0,
      totalTickets: 100,
      status: 'active',
      startDate: DateTime.now(),
    );
  });

  Widget createWidgetUnderTest() {
    final changeParticipant = ChangeParticipant(mockRepository);
    final getEventCategories = GetEventCategories(mockRepository);
    final getEventTicketsDetailed = GetEventTicketsDetailed(mockRepository);
    
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ChangeParticipant>.value(value: changeParticipant),
        RepositoryProvider<GetEventCategories>.value(value: getEventCategories),
        RepositoryProvider<GetEventTicketsDetailed>.value(value: getEventTicketsDetailed),
      ],
      child: BlocProvider(
        create: (context) => ParticipantBloc(
          getEventParticipantsDetailed: GetEventParticipantsDetailed(repository: mockRepository),
          searchParticipants: SearchParticipants(repository: mockRepository),
          changeParticipant: changeParticipant,
        ),
        child: MaterialApp(
          home: EditParticipantPage(
            participant: testParticipant,
            event: testEvent,
          ),
        ),
      ),
    );
  }

  testWidgets('Debe validar que la información se cambia correctamente y el ticket sigue siendo el mismo', (WidgetTester tester) async {
    // 1. Cargar la página
    await tester.pumpWidget(createWidgetUnderTest());

    // Esperar carga inicial
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 2. Modificar el nombre, apellido y email
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Pedro');
    await tester.enterText(find.widgetWithText(TextFormField, 'Apellido'), 'García');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'pedro@test.com');

    // 3. Guardar cambios
    final saveButton = find.text('GUARDAR CAMBIOS');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    
    // Esperar procesamiento
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 4. Validaciones
    
    // Validar que se llamó al repositorio con los mismos IDs
    expect(mockRepository.lastOrderId, equals('ORDER123'));
    expect(mockRepository.lastParticipantId, equals('VAL123'));
    
    // Validar que la información en data cambió correctamente
    expect(mockRepository.lastData?['name'], equals('Pedro'));
    expect(mockRepository.lastData?['lastName'], equals('García'));
    expect(mockRepository.lastData?['email'], equals('pedro@test.com'));
    
    // Validar que el ticketId en la data sigue siendo el mismo
    expect(mockRepository.lastData?['ticketId'], equals('ticket1'));
  });
}
