import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tocke/features/events/presentation/pages/event_detail_page.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/read_history_service.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../events/presentation/bloc/event_bloc.dart';
import '../../../search/data/services/rut_ticket_search_service.dart';
import '../../../search/presentation/pages/rut_ticket_search_page.dart';
import '../../../events/presentation/pages/participant_search_edit_page.dart';

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
  Map<String, dynamic>? userData;
  Map<String, dynamic>? organizerProfile;
  int _scannedCount = 0;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadScannedCount();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'v${info.version}';
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _AppDrawer(
        organizerName: _organizerName,
        isTeamMember: _isTeamMember,
        onSearchByRut: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => RutTicketSearchPage(
                    searchService: context.read<RutTicketSearchService>(),
                  ),
            ),
          );
        },
        onParticipantEdit: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => ParticipantSearchEditPage(
                    searchService: context.read<RutTicketSearchService>(),
                  ),
            ),
          );
        },
        onLogout: () async {
          Navigator.of(context).pop();
          await _handleLogout();
        },
      ),
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
                    const SizedBox(height: 16),
                    if (_appVersion.isNotEmpty)
                      Center(
                        child: Text(
                          _appVersion,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
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

class _AppDrawer extends StatelessWidget {
  final String organizerName;
  final bool isTeamMember;
  final VoidCallback onSearchByRut;
  final VoidCallback onParticipantEdit;
  final VoidCallback onLogout;

  const _AppDrawer({
    required this.organizerName,
    required this.isTeamMember,
    required this.onSearchByRut,
    required this.onParticipantEdit,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.7),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/logo.jpg', height: 36),
                  const SizedBox(height: 12),
                  Text(
                    isTeamMember ? organizerName : 'Validador',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Accesos rápidos',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.search, color: AppColors.primary),
              title: const Text('Buscar por RUT'),
              subtitle: const Text('Tickets en eventos permitidos'),
              onTap: onSearchByRut,
            ),
            ListTile(
              leading: const Icon(Icons.edit_note, color: AppColors.primary),
              title: const Text('Modificar Participante'),
              subtitle: const Text('Editar datos por RUT/Pasaporte'),
              onTap: onParticipantEdit,
            ),
            const Spacer(),
            const Divider(color: AppColors.border, height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.textSecondary),
              title: const Text('Cerrar sesión'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
