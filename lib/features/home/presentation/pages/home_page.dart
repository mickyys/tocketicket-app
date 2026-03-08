import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tocke/features/events/domain/usecases/get_attendee_status_summary.dart';
import 'package:tocke/features/events/presentation/pages/event_detail_page.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/read_history_service.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../events/presentation/bloc/event_bloc.dart';
import '../../../events/domain/usecases/get_events.dart';
import '../../../events/domain/usecases/synchronize_event_attendees.dart';
import '../../../events/domain/usecases/synchronize_participants.dart';
import '../../../scanner/presentation/pages/scan_history_page.dart';
import '../../../scanner/presentation/pages/qr_scanner_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomePageContent();
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  int _selectedIndex = 0;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? organizerProfile;
  int _scannedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadScannedCount();
  }

  Future<void> _loadScannedCount() async {
    final count = await ReadHistoryService.getHistory();
    if (mounted) {
      setState(() {
        _scannedCount = count.length;
      });
    }
  }

  Future<void> _loadUserData() async {
    final data = await AuthService.getUserData();
    final profile = await AuthService.getOrganizerProfile();
    if (mounted) {
      setState(() {
        userData = data;
        organizerProfile = profile;
      });
    }
  }

  bool get _isTeamMember {
    if (organizerProfile == null) return false;
    final roles = (userData?['roles'] as List?)?.cast<String>() ?? [];
    return !roles.contains('organizer') && !roles.contains('admin');
  }

  String get _organizerName =>
      organizerProfile?['legal_name']?.toString() ??
      organizerProfile?['name']?.toString() ??
      'Equipo';

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Eventos - stay on home
        break;
      case 1:
        // Scanner QR
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder:
                    (context) => QRScannerPage(onScanSaved: _loadScannedCount),
              ),
            )
            .then((_) {
              // Recargar contador cuando vuelve del scanner
              _loadScannedCount();
            });
        break;
      case 2:
        // History
        Navigator.of(context)
            .push(
              MaterialPageRoute(builder: (context) => const ScanHistoryPage()),
            )
            .then((_) {
              // Recargar contador cuando vuelve del historial
              _loadScannedCount();
            });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo.jpg', height: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tocke',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _isTeamMember ? _organizerName : 'Validador',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: _handleLogout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      // Body
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is EventError) {
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
                    state.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
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

          if (state is EventLoaded) {
            final events = state.events;

            if (events.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<EventBloc>().add(FetchEvents());
                  await _loadScannedCount();
                },
                child: ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay eventos disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              context.read<EventBloc>().add(FetchEvents());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                            ),
                            child: const Text('Actualizar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<EventBloc>().add(FetchEvents());
                await _loadScannedCount();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.padding,
                  AppConstants.padding,
                  AppConstants.padding,
                  120, // Espacio para BottomNav
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Estadísticas rápidas
                    QuickStatsCard(
                      eventsCount: events.length,
                      scannedCount: _scannedCount,
                      todayCount: 0,
                    ),
                    const SizedBox(height: 24),

                    // Título de eventos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Eventos Disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${events.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Lista de eventos reales
                    _buildEventsList(events),
                  ],
                ),
              ),
            );
          }

          context.read<EventBloc>().add(FetchEvents());
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
      ),
    );
  }

  Widget _buildEventsList(List events) {
    return Column(
      children: List.generate(events.length, (index) {
        final event = events[index];
        // Formatear fecha manualmente sin dependencia de locale data
        final months = [
          'enero',
          'febrero',
          'marzo',
          'abril',
          'mayo',
          'junio',
          'julio',
          'agosto',
          'septiembre',
          'octubre',
          'noviembre',
          'diciembre',
        ];
        final day = event.startDate.day;
        final month = months[event.startDate.month - 1];
        final year = event.startDate.year;
        final formattedDate = '$day $month $year';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EventCard(
            eventName: event.name,
            date: formattedDate,
            location: event.location,
            totalTickets: event.totalTickets,
            active: event.status == 'published',
            onTap: () {
              final eventBloc = context.read<EventBloc>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) =>
                          EventDetailPage(event: event, eventBloc: eventBloc),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
