import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/get_event_participants_detailed.dart';
import '../../domain/usecases/search_participants.dart';
import '../../domain/usecases/synchronize_participants.dart';
import '../../domain/usecases/clear_local_cache.dart';
import '../bloc/participant_bloc.dart';
import '../bloc/event_bloc.dart';

class EventParticipantsPage extends StatelessWidget {
  final Event event;
  final EventBloc eventBloc;

  const EventParticipantsPage({
    super.key,
    required this.event,
    required this.eventBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => ParticipantBloc(
                getEventParticipantsDetailed:
                    context.read<GetEventParticipantsDetailed>(),
                searchParticipants: context.read<SearchParticipants>(),
                synchronizeParticipants:
                    context.read<SynchronizeParticipants>(),
                clearLocalCache: context.read<ClearLocalCache>(),
              ),
        ),
        BlocProvider<EventBloc>.value(value: eventBloc),
      ],
      child: EventParticipantsView(event: event),
    );
  }
}

class EventParticipantsView extends StatefulWidget {
  final Event event;

  const EventParticipantsView({super.key, required this.event});

  @override
  State<EventParticipantsView> createState() => _EventParticipantsViewState();
}

class _EventParticipantsViewState extends State<EventParticipantsView> {
  late ScrollController _horizontalScroller;
  late ScrollController _verticalScroller;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _horizontalScroller = ScrollController();
    _verticalScroller = ScrollController();
    _verticalScroller.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadParticipants();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty && _isSearchActive) {
      setState(() => _isSearchActive = false);
      _loadParticipants();
    } else if (_searchController.text.isNotEmpty) {
      context.read<ParticipantBloc>().add(
        SearchParticipantsEvent(
          eventId: widget.event.id,
          query: _searchController.text,
        ),
      );
    }
  }

  Future<void> _handleSynchronize() async {
    final token = await AuthService.getAccessToken() ?? '';
    if (mounted && token.isNotEmpty) {
      // Notificar al EventBloc que está sincronizando
      context.read<EventBloc>().add(
        SynchronizeEventAttendeesEvent(widget.event.id),
      );

      // Disparar sincronización en ParticipantBloc
      context.read<ParticipantBloc>().add(
        SynchronizeParticipantsEvent(eventId: widget.event.id, token: token),
      );
    }
  }

  void _showClearCacheConfirmation() {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Limpiar caché',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: const Text(
              '¿Estás seguro de que deseas eliminar todos los participantes cacheados? Los datos se sincronizarán nuevamente cuando sea necesario.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleClearCache();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  void _handleClearCache() {
    context.read<ParticipantBloc>().add(
      ClearLocalCacheEvent(eventId: widget.event.id),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Caché eliminado'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onScroll() {
    if (!_verticalScroller.hasClients) return;

    if (_verticalScroller.position.pixels >=
        _verticalScroller.position.maxScrollExtent * 0.8) {
      final state = context.read<ParticipantBloc>().state;
      if (state is ParticipantLoaded && !state.isLoadingMore) {
        final currentPage = state.pagination['currentPage'] ?? 1;
        final totalPages = state.pagination['totalPages'] ?? 1;

        if (currentPage < totalPages) {
          _loadNextPage(currentPage + 1);
        }
      }
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map(
          (word) =>
              word.isEmpty
                  ? ''
                  : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  String _formatRut(String rut) {
    if (rut.isEmpty) return rut;

    // Eliminar espacios y convertir a mayúsculas
    rut =
        rut
            .replaceAll('.', '')
            .replaceAll('-', '')
            .replaceAll(' ', '')
            .toUpperCase();

    // Si no tiene al menos 8 caracteres, retornar como está
    if (rut.length < 8) return rut;

    // Extraer el dígito verificador (último carácter)
    final verificador = rut.substring(rut.length - 1);
    final rutNumeros = rut.substring(0, rut.length - 1);

    // Formatear: XX.XXX.XXX-K
    final formatted = rutNumeros.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)}.',
    );

    return '$formatted-$verificador';
  }

  Future<void> _loadParticipants() async {
    final token = await AuthService.getAccessToken() ?? '';
    if (mounted) {
      context.read<ParticipantBloc>().add(
        FetchParticipantsEvent(eventId: widget.event.id, token: token),
      );
    }
  }

  Future<void> _loadNextPage(int nextPage) async {
    final token = await AuthService.getAccessToken() ?? '';
    if (mounted) {
      context.read<ParticipantBloc>().add(
        FetchParticipantsEvent(
          eventId: widget.event.id,
          token: token,
          page: nextPage,
          pageSize: 10,
          isLoadMore: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _horizontalScroller.dispose();
    _verticalScroller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:
            _isSearchActive
                ? TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o RUT',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  style: const TextStyle(color: AppColors.white),
                )
                : Text(
                  'Participantes - ${widget.event.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          if (!_isSearchActive)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() => _isSearchActive = true);
              },
            ),
          if (_isSearchActive)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                setState(() => _isSearchActive = false);
              },
            ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _handleSynchronize,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_cache') {
                _showClearCacheConfirmation();
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'clear_cache',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Limpiar caché'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: BlocBuilder<ParticipantBloc, ParticipantState>(
        builder: (context, state) {
          if (state is ParticipantLoading) {
            return _buildLoadingWidget();
          } else if (state is ParticipantLoaded) {
            if (state.participants.isEmpty) {
              return _buildEmptyState();
            }
            return _buildParticipantsTable(state);
          } else if (state is ParticipantError) {
            return _buildErrorState(state.message);
          }
          return _buildInitialState();
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cargando participantes...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: const Icon(
              Icons.people_outline,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay participantes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Los participantes aparecerán aquí una vez que se registren',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Error al cargar participantes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: message));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mensaje copiado al portapapeles'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copiar error'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadParticipants,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _loadParticipants,
        icon: const Icon(Icons.refresh),
        label: const Text('Cargar Participantes'),
      ),
    );
  }

  Widget _buildParticipantsTable(ParticipantLoaded state) {
    return RefreshIndicator(
      onRefresh: _loadParticipants,
      child: SingleChildScrollView(
        controller: _verticalScroller,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Detalles adicionales (Resumen)
              if (state.participants.isNotEmpty)
                _buildDetailedInfo(state.participants),

              const SizedBox(height: 24),

              // Info de paginación
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${state.pagination['totalRecords'] ?? 0} participantes',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tabla
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScroller,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DataTable(
                    columnSpacing: 20,
                    horizontalMargin: 16,
                    headingRowColor: MaterialStateProperty.all(
                      AppColors.primary.withValues(alpha: 0.1),
                    ),
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    dataTextStyle: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                    columns: [
                      DataColumn(
                        label: const Text('#'),
                        onSort: (index, ascending) {},
                      ),
                      DataColumn(
                        label: const Text('Nombre'),
                        onSort: (index, ascending) {},
                      ),
                      DataColumn(
                        label: const Text('Documento'),
                        onSort: (index, ascending) {},
                      ),
                      DataColumn(
                        label: const Text('Categoría'),
                        onSort: (index, ascending) {},
                      ),
                      DataColumn(
                        label: const Text('Ticket'),
                        onSort: (index, ascending) {},
                      ),
                      DataColumn(
                        label: const Text('Estado'),
                        onSort: (index, ascending) {},
                      ),
                      DataColumn(
                        label: const Text('Validado'),
                        onSort: (index, ascending) {},
                      ),
                    ],
                    rows: List<DataRow>.generate(state.participants.length, (
                      index,
                    ) {
                      final participant = state.participants[index];
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _capitalize(participant.participantName),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataCell(
                            Text(
                              _formatRut(participant.participantDocumentNumber),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataCell(
                            Text(
                              participant.categoryName ?? 'N/A',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                participant.ticketName ?? 'N/A',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          DataCell(_buildStatusBadge(participant.ticketStatus)),
                          DataCell(
                            participant.validatedAt != null
                                ? Text(
                                  DateFormat(
                                    'dd/MM/yy HH:mm',
                                  ).format(participant.validatedAt!),
                                  style: const TextStyle(fontSize: 12),
                                )
                                : const Text(
                                  'Pendiente',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Indicador de carga más participantes
              if (state.isLoadingMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Cargando más participantes...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String displayText;

    switch (status.toLowerCase()) {
      case 'validated':
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        icon = Icons.check_circle;
        displayText = 'Válido';
        break;
      case 'valid':
        bgColor = AppColors.secondary.withValues(alpha: 0.1);
        textColor = AppColors.secondary;
        icon = Icons.check;
        displayText = 'Válido';
        break;
      case 'invalid_replaced':
      case 'invalid_cancelled':
      case 'invalid_reversed':
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        icon = Icons.cancel;
        displayText = 'Inválido';
        break;
      case 'expired':
        bgColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        icon = Icons.schedule;
        displayText = 'Expirado';
        break;
      default:
        bgColor = AppColors.background.withValues(alpha: 0.5);
        textColor = AppColors.textSecondary;
        icon = Icons.help_outline;
        displayText = 'Pendiente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            displayText,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfo(List participants) {
    // Calcular estadísticas
    int validatedCount = 0;
    int invalidCount = 0;
    int totalCount = participants.length;

    for (var p in participants) {
      if (p.ticketStatus == 'validated' || p.ticketStatus == 'valid') {
        validatedCount++;
      } else if (p.ticketStatus.contains('invalid')) {
        invalidCount++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total',
                value: '$totalCount',
                color: AppColors.primary,
                icon: Icons.people,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Validados',
                value: '$validatedCount',
                color: AppColors.success,
                icon: Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'No Validados',
                value: '$invalidCount',
                color: AppColors.error,
                icon: Icons.cancel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
