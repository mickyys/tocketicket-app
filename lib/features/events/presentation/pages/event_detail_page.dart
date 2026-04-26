import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tocke/features/scanner/presentation/pages/scan_history_page.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/read_history_service.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../scanner/presentation/pages/qr_scanner_page.dart';
import '../../../scanner/presentation/bloc/scanner_bloc.dart';
import '../../../scanner/domain/usecases/check_ticket_status.dart';
import '../../../scanner/domain/usecases/validate_ticket_qr.dart';
import '../../../scanner/domain/usecases/update_ticket_runner_data.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/participant.dart';
import '../../domain/usecases/change_participant.dart';
import '../../domain/entities/attendee_status_summary.dart';
import '../../domain/usecases/get_event_participants_detailed.dart';
import '../../domain/usecases/search_participants.dart';
import '../bloc/participant_bloc.dart';
import '../bloc/event_bloc.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;
  final EventBloc eventBloc;

  const EventDetailPage({
    super.key,
    required this.event,
    required this.eventBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            debugPrint(
              '[EventDetail] [1] Creando ParticipantBloc para evento ${event.id}',
            );
            return ParticipantBloc(
              getEventParticipantsDetailed:
                  context.read<GetEventParticipantsDetailed>(),
              searchParticipants: context.read<SearchParticipants>(),
              changeParticipant: context.read<ChangeParticipant>(),
            );
          },
        ),
        BlocProvider<EventBloc>.value(
          value: () {
            print(
              '[EventDetail] [2] Lanzando GetAttendeeStatusSummaryEvent para evento ${event.id} (bloc#${eventBloc.hashCode})',
            );
            eventBloc.add(GetAttendeeStatusSummaryEvent(event.id));
            return eventBloc;
          }(),
        ),
      ],
      child: EventDetailView(event: event),
    );
  }
}

class EventDetailView extends StatefulWidget {
  final Event event;

  const EventDetailView({super.key, required this.event});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  String _lastScanText = '--:--';
  bool _isSyncing = true;
  bool _syncError = false;

  // Cache del último summary recibido del servidor.
  // Se guarda aquí para que no se pierda cuando el EventBloc emite otros estados.
  int _confirmedCount = 0;
  int _unconfirmedCount = 0;
  int _totalAttendees = 0;
  List<CategoryScanInfo>? _byCategory;
  bool? _enableChipId;
  bool? _enableRunnerNumber;
  bool _summaryLoaded = false;

  Future<void> _refreshParticipants() async {
    final token = await AuthService.getAccessToken() ?? '';
    if (!mounted) return;

    context.read<ParticipantBloc>().add(
      FetchParticipantsEvent(
        eventId: widget.event.id,
        token: token,
        pageSize: 1000,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadLastScan();
    _isSyncing = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshParticipants();
    });
  }

  void _onParticipantStateChange(BuildContext context, ParticipantState state) {
    print('[EventDetail] ParticipantState → ${state.runtimeType}');
    if (state is ParticipantLoaded && !state.isLoadingMore) {
      final eventBloc = context.read<EventBloc>();
      print(
        '[EventDetail] [5] ParticipantLoaded: ${state.participants.length} participantes. '
        'Lanzando GetAttendeeStatusSummaryEvent en bloc#${eventBloc.hashCode}.',
      );
      if (_isSyncing) {
        setState(() => _isSyncing = false);
      }
      eventBloc.add(GetAttendeeStatusSummaryEvent(widget.event.id));
    } else if (state is ParticipantError) {
      if (_isSyncing || !_syncError) {
        setState(() {
          _isSyncing = false;
          _syncError = true;
        });
      }
    }
  }

  Future<void> _loadLastScan() async {
    final history = await ReadHistoryService.getHistory();
    final eventScans =
        history.where((r) => r.eventName == widget.event.name).toList();
    if (eventScans.isNotEmpty) {
      // Ya vienen ordenados desc por timestamp
      final last = eventScans.first.timestamp;
      if (mounted) {
        setState(() {
          _lastScanText =
              '${last.hour}:${last.minute.toString().padLeft(2, '0')}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return BlocListener<ParticipantBloc, ParticipantState>(
      listener: _onParticipantStateChange,
      child: BlocListener<EventBloc, EventState>(
        listener: (context, eventState) {
          if (eventState is AttendeeStatusSummaryLoaded &&
              eventState.eventId == event.id) {
            print(
              '[EventDetail] BlocListener: summary recibido confirmed=${eventState.summary.confirmed} unconfirmed=${eventState.summary.unconfirmed} total=${eventState.summary.total}',
            );
            setState(() {
              _confirmedCount = eventState.summary.confirmed;
              _unconfirmedCount = eventState.summary.unconfirmed;
              _totalAttendees = eventState.summary.total;
              _byCategory = eventState.summary.byCategory;
              _enableChipId = eventState.summary.enableChipId;
              _enableRunnerNumber = eventState.summary.enableRunnerNumber;
              _summaryLoaded = true;
            });
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Image.asset(
              'assets/images/tocke_logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Text('Tocke'),
            ),
            centerTitle: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child:
                    _isSyncing
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                        : Icon(
                          _syncError ? Icons.sync_problem : Icons.cloud_done,
                          size: 20,
                          color: _syncError ? Colors.amber : AppColors.primary,
                        ),
              ),
            ],
          ),
          body: BlocBuilder<EventBloc, EventState>(
            builder: (context, eventState) {
              final bool summaryIsLoading =
                  !_summaryLoaded && eventState is AttendeeStatusSummaryLoading;

              int confirmedCount = _summaryLoaded ? _confirmedCount : 0;
              int totalAttendees =
                  _summaryLoaded
                      ? _totalAttendees
                      : (event.totalTickets > 0 ? event.totalTickets : 0);
              int unconfirmedCount = _summaryLoaded ? _unconfirmedCount : 0;
              final List<CategoryScanInfo>? byCategoryFromSummary =
                  _summaryLoaded ? _byCategory : null;

              return BlocBuilder<ParticipantBloc, ParticipantState>(
                builder: (context, state) {
                  List<Participant> participants = [];
                  // Usar un mapa para agrupar por categoría
                  // Priorizamos los datos del resumen si están disponibles
                  Map<String, List<Participant>> categories = {};

                  if (state is ParticipantLoaded) {
                    participants = state.participants;

                    // Agrupar por categoría usando los participantes cargados localmente
                    for (var p in participants) {
                      final category = p.categoryName ?? 'Sin Categoría';
                      if (!categories.containsKey(category)) {
                        categories[category] = [];
                      }
                      categories[category]!.add(p);
                    }

                    // Fallback local sólo cuando la API ya terminó (error o sin datos);
                    // durante la carga no sobreescribimos para evitar mostrar datos obsoletos.
                    if (!summaryIsLoading &&
                        confirmedCount == 0 &&
                        participants.isNotEmpty) {
                      confirmedCount =
                          participants
                              .where(
                                (p) =>
                                    p.ticketStatus == 'validated' ||
                                    p.validatedAt != null,
                              )
                              .length;
                      totalAttendees = participants.length;
                      unconfirmedCount = totalAttendees - confirmedCount;
                    }
                  }

                  final progressPercent =
                      totalAttendees > 0
                          ? (confirmedCount / totalAttendees * 100).round()
                          : 0;

                  final isChipEnabled = _enableChipId ?? true;
                  final isRunnerEnabled = _enableRunnerNumber ?? true;
                  final showPendingChip = isChipEnabled || isRunnerEnabled;

                  final pendingChip =
                      showPendingChip
                          ? participants
                              .where(
                                (p) =>
                                    (p.ticketStatus == 'validated' ||
                                        p.validatedAt != null) &&
                                    (p.chipId == null || p.chipId!.isEmpty),
                              )
                              .length
                          : 0;

                  // Último escaneo — leído desde ReadHistoryService en initState
                  final lastScanText = _lastScanText;

                  return RefreshIndicator(
                    onRefresh: () async {
                      await _loadLastScan();
                      final token = await AuthService.getAccessToken() ?? '';
                      if (context.mounted) {
                        context.read<ParticipantBloc>().add(
                          FetchParticipantsEvent(
                            eventId: event.id,
                            token: token,
                            pageSize: 1000,
                          ),
                        );
                        context.read<EventBloc>().add(
                          GetAttendeeStatusSummaryEvent(event.id),
                        );
                      }
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título y Badge
                          _buildEventHeader(event),
                          const SizedBox(height: 16),

                          // Progreso de Check-in
                          _buildProgressCard(
                            confirmedCount,
                            totalAttendees,
                            progressPercent,
                          ),
                          const SizedBox(height: 16),

                          // Grid de Métricas
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.3,
                            children: [
                              _buildStatCard(
                                icon: Icons.check_circle_outline,
                                value: '$confirmedCount',
                                label: 'Asistentes confirmados',
                                highlight: true,
                              ),
                              _buildStatCard(
                                icon: Icons.access_time,
                                value: lastScanText,
                                label: 'Último escaneo',
                              ),
                              if (showPendingChip)
                                _buildStatCard(
                                  icon: Icons.warning_amber_rounded,
                                  value: '$pendingChip',
                                  label: 'Sin chip/corredor',
                                  color: pendingChip > 0 ? Colors.amber : null,
                                ),
                              _buildStatCard(
                                icon: Icons.people_outline,
                                value: '$unconfirmedCount',
                                label: 'Sin confirmar',
                              ),
                            ],
                          ),
                          if (showPendingChip) const SizedBox(height: 16),

                          // Alerta pendientes
                          if (showPendingChip && pendingChip > 0)
                            _buildPendingAlert(pendingChip),
                          if (showPendingChip && pendingChip > 0)
                            const SizedBox(height: 24),

                          // Por Categoría
                          if (byCategoryFromSummary != null &&
                              byCategoryFromSummary.isNotEmpty) ...[
                            const Row(
                              children: [
                                Icon(
                                  Icons.style,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Por Categoría',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...byCategoryFromSummary.map(
                              (cat) => _buildCategoryInfoCard(cat),
                            ),
                            const SizedBox(height: 24),
                          ] else if (categories.isNotEmpty) ...[
                            const Row(
                              children: [
                                Icon(
                                  Icons.style,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Por Categoría (Carga Local)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...categories.entries.map(
                              (entry) =>
                                  _buildCategoryCard(entry.key, entry.value),
                            ),
                            const SizedBox(height: 24),
                          ],

                          const SizedBox(
                            height: 100,
                          ), // Espacio extra para el BottomNavigationBar
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: -1, // Ninguno seleccionado en esta vista de detalle
            onTap: (index) async {
              if (index == 1) {
                // Historial - Antes enviaba a EventParticipantsPage por error
                final checkTicketStatus = context.read<CheckTicketStatus>();
                final validateTicketQR = context.read<ValidateTicketQR>();
                final updateTicketRunnerData =
                    context.read<UpdateTicketRunnerData>();

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => BlocProvider(
                          create:
                              (context) => ScannerBloc(
                                checkTicketStatus: checkTicketStatus,
                                validateTicketQR: validateTicketQR,
                                updateTicketRunnerData: updateTicketRunnerData,
                              ),
                          child: const ScanHistoryPage(),
                        ),
                  ),
                );
              } else if (index == 0) {
                // Escanear - Ahora es índice 0 según BottomNavBar
                final checkTicketStatus = context.read<CheckTicketStatus>();
                final validateTicketQR = context.read<ValidateTicketQR>();
                final updateTicketRunnerData =
                    context.read<UpdateTicketRunnerData>();
                final participantBloc = context.read<ParticipantBloc>();
                final eventBloc = context.read<EventBloc>();

                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create:
                                    (context) => ScannerBloc(
                                      checkTicketStatus: checkTicketStatus,
                                      validateTicketQR: validateTicketQR,
                                      updateTicketRunnerData:
                                          updateTicketRunnerData,
                                    ),
                              ),
                              BlocProvider.value(value: participantBloc),
                            ],
                            child: QRScannerPage(
                              eventId: event.id,
                              eventName: event.name,
                              onScanSaved: () {
                                _refreshParticipants();
                                // Refrescar el resumen de asistentes tras cada escaneo.
                                eventBloc.add(
                                  GetAttendeeStatusSummaryEvent(event.id),
                                );
                              },
                            ),
                          ),
                    ),
                  );
                }
              }
            },
          ),
        ),
      ), // BlocListener<EventBloc>
    );
  }

  Widget _buildEventHeader(Event event) {
    // Formatear fecha manualmente para evitar errores de locale data no inicializada
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
    final days = [
      'domingo',
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
    ];

    String formattedDate = 'Fecha por confirmar';
    if (event.startDate != null) {
      final startDate = event.startDate!;
      final dayName = days[startDate.weekday % 7];
      final day = startDate.day;
      final month = months[startDate.month - 1];
      final year = startDate.year;
      formattedDate = '$dayName, $day de $month de $year';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _StatusBadge(status: event.status),
          const SizedBox(height: 16),
          _IconInfoRow(
            icon: Icons.calendar_today_outlined,
            text: formattedDate,
          ),
          const SizedBox(height: 8),
          _IconInfoRow(icon: Icons.location_on_outlined, text: event.location),
          const SizedBox(height: 8),
          _IconInfoRow(
            icon: Icons.people_outline,
            text: '${event.totalTickets} entradas totales',
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int checkedIn, int total, int percent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.trending_up, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Progreso Check-in',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 12,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$checkedIn confirmados',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                'de $total totales',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    bool highlight = false,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color:
            highlight
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              highlight
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color:
                color ??
                (highlight ? AppColors.primary : AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAlert(int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count ${count == 1 ? 'participante pendiente' : 'participantes pendientes'}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  'Escaneados sin chip o número de corredor asignado',
                  style: TextStyle(color: Colors.amber, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInfoCard(CategoryScanInfo category) {
    final validated = category.confirmed;
    final total = category.total;
    final percent = total > 0 ? (validated / total * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.categoryName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$validated/$total',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    String name,
    List<Participant> categoryParticipants,
  ) {
    final validated =
        categoryParticipants.where((p) => p.validatedAt != null).length;
    final total = categoryParticipants.length;
    final percent = total > 0 ? (validated / total * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$validated/$total',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'active':
      case 'ongoing':
        bgColor = AppColors.success.withValues(alpha: 0.2);
        textColor = AppColors.success;
        label = 'En Curso';
        break;
      case 'upcoming':
        bgColor = AppColors.info.withValues(alpha: 0.2);
        textColor = AppColors.info;
        label = 'Próximo';
        break;
      default:
        bgColor = AppColors.border.withValues(alpha: 0.2);
        textColor = AppColors.textSecondary;
        label = 'Finalizado';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status.toLowerCase() == 'active' ||
              status.toLowerCase() == 'ongoing')
            Container(
              margin: const EdgeInsets.only(right: 6),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
