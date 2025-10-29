import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../scanner/presentation/pages/qr_scanner_page.dart';
import '../../../scanner/presentation/pages/scan_history_page.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/synchronize_event_attendees.dart';
import '../bloc/event_bloc.dart';

class OrganizerEventsPage extends StatelessWidget {
  const OrganizerEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventBloc(
        synchronizeEventAttendees: context.read<SynchronizeEventAttendees>(),
        getEvents: context.read<GetEvents>(),
      )..add(FetchEvents()),
      child: const OrganizerEventsView(),
    );
  }
}

class OrganizerEventsView extends StatefulWidget {
  const OrganizerEventsView({super.key});

  @override
  State<OrganizerEventsView> createState() => _OrganizerEventsViewState();
}

class _OrganizerEventsViewState extends State<OrganizerEventsView> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await AuthService.getUserData();
    if (mounted) {
      setState(() {
        userData = data;
      });
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Eventos'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EventBloc>().add(FetchEvents());
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is SyncSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Evento sincronizado con éxito'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is SyncFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al sincronizar: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Column(
          children: [
            if (userData != null) _buildUserInfo(),
            Expanded(child: _buildEventsList()),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppConstants.padding),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón de historial de escaneos
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ScanHistoryPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.history,
                  size: 28,
                  color: AppColors.primary,
                ),
                tooltip: 'Historial de escaneos',
              ),
              // Botón central del escáner QR
              Container(
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const QRScannerPage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    size: 32,
                    color: AppColors.white,
                  ),
                  iconSize: 32,
                  padding: const EdgeInsets.all(16),
                  tooltip: 'Escanear QR',
                ),
              ),
              // Espacio para equilibrar el diseño
              const SizedBox(width: 28 + 16), // Tamaño del ícono + padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.padding),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: const Border(bottom: BorderSide(color: AppColors.greyLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido, ${userData!['name'] ?? userData!['email'] ?? 'Usuario'}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (userData!['email'] != null)
            Text(
              userData!['email'],
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando eventos...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return BlocBuilder<EventBloc, EventState>(
      buildWhen: (previous, current) {
        // Solo rebuild para estados de eventos, no para sync
        return current is EventInitial ||
            current is EventLoading ||
            current is EventLoaded ||
            current is EventError;
      },
      builder: (context, state) {
        if (state is EventLoading || state is EventInitial) {
          return _buildLoading();
        } else if (state is EventLoaded) {
          if (state.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_note,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes eventos aún',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea tu primer evento para comenzar',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navegar a crear evento
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Crear evento - Funcionalidad pendiente',
                          ),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Evento'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<EventBloc>().add(FetchEvents());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.padding),
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                final event = state.events[index];
                return _buildEventCard(event, state);
              },
            ),
          );
        } else if (state is EventError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar eventos',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: const TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<EventBloc>().add(FetchEvents());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        // Con buildWhen, este caso no debería ocurrir
        return _buildLoading();
      },
    );
  }

  Widget _buildEventCard(Event event, EventState currentState) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.margin),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        onTap: () {
          // TODO: Navegar a detalles del evento
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ver detalles de: ${event.name}'),
              backgroundColor: AppColors.info,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (currentState is SyncInProgress &&
                      currentState.eventId == event.id)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.sync, color: AppColors.primary),
                      onPressed: () {
                        context.read<EventBloc>().add(
                          SynchronizeEventAttendeesEvent(event.id),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${event.startDate.toLocal()}'.split(' ')[0],
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location,
                      style: const TextStyle(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entradas vendidas: ${event.ticketsSold}/${event.totalTickets}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: event.totalTickets > 0
                              ? event.ticketsSold / event.totalTickets
                              : 0,
                          backgroundColor: AppColors.greyLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            event.totalTickets > 0 &&
                                    (event.ticketsSold / event.totalTickets) >=
                                        0.9
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${event.totalTickets > 0 ? (event.ticketsSold / event.totalTickets * 100).round() : 0}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
