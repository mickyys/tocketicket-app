import 'package:flutter/material.dart';
import 'package:tocke/core/constants/app_colors.dart';
import 'package:tocke/core/utils/document_formatter.dart';
import 'package:tocke/features/search/data/models/rut_ticket_search_result_model.dart';
import 'package:tocke/features/search/data/services/rut_ticket_search_service.dart';
import 'package:tocke/features/events/presentation/pages/edit_participant_page.dart';

class ParticipantSearchEditPage extends StatefulWidget {
  final RutTicketSearchService searchService;

  const ParticipantSearchEditPage({super.key, required this.searchService});

  @override
  State<ParticipantSearchEditPage> createState() => _ParticipantSearchEditPageState();
}

class _ParticipantSearchEditPageState extends State<ParticipantSearchEditPage> {
  final TextEditingController _documentController = TextEditingController();
  final FocusNode _documentFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;
  List<RutTicketSearchResultModel> _results = const [];
  String _documentType = 'rut';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _documentFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _documentController.dispose();
    _documentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final rawValue = _documentController.text.trim();
    final cleanedDocument =
        _documentType == 'rut'
            ? DocumentFormatter.cleanDocument(rawValue)
            : rawValue;

    if (cleanedDocument.isEmpty) {
      setState(() {
        _errorMessage =
            _documentType == 'rut'
                ? 'Ingresa un RUT para buscar.'
                : 'Ingresa un pasaporte para buscar.';
        _results = const [];
      });
      return;
    }

    if (_documentType == 'rut' && !DocumentFormatter.validateRut(cleanedDocument)) {
      setState(() {
        _errorMessage = 'El RUT ingresado no es válido.';
        _results = const [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await widget.searchService.searchByDocument(
        documentType: _documentType,
        documentNumber: cleanedDocument,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _results = const [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _documentController.clear();
      _errorMessage = null;
      _results = const [];
    });
  }

  void _onDocumentChanged(String value) {
    if (_documentType != 'rut') return;

    final formatted = DocumentFormatter.formatRut(
      DocumentFormatter.cleanDocument(value),
    );

    if (formatted == value) return;

    _documentController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _onDocumentTypeChanged(String documentType) {
    if (_documentType == documentType) return;

    final currentText = _documentController.text;
    final nextText =
        documentType == 'rut'
            ? DocumentFormatter.formatRut(
              DocumentFormatter.cleanDocument(currentText),
            )
            : DocumentFormatter.cleanDocument(currentText);

    setState(() {
      _documentType = documentType;
      _documentController.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
      _errorMessage = null;
      _results = const [];
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Fecha sin definir';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _ticketStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'validated':
        return 'Validado';
      case 'active':
        return 'Activo';
      default:
        return 'Pendiente';
    }
  }

  Color _ticketStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'validated':
        return AppColors.success;
      case 'active':
        return AppColors.info;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Modificar Participante'),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Busca al participante por documento para modificar sus datos.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'rut',
                          label: Text('RUT'),
                          icon: Icon(Icons.badge_outlined),
                        ),
                        ButtonSegment<String>(
                          value: 'pasaporte',
                          label: Text('Pasaporte'),
                          icon: Icon(Icons.book_outlined),
                        ),
                      ],
                      selected: {_documentType},
                      onSelectionChanged:
                          (selection) =>
                              _onDocumentTypeChanged(selection.first),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _documentController,
                      focusNode: _documentFocusNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      onChanged: _onDocumentChanged,
                      onSubmitted: (_) => _search(),
                      decoration: InputDecoration(
                        labelText: _documentType == 'rut' ? 'RUT' : 'Pasaporte',
                        hintText:
                            _documentType == 'rut'
                                ? '12.345.678-9'
                                : 'AB1234567',
                        prefixIcon: Icon(
                          _documentType == 'rut'
                              ? Icons.badge_outlined
                              : Icons.book_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _search,
                        icon:
                            _isLoading
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                                : const Icon(Icons.search),
                        label: Text(_isLoading ? 'Buscando...' : 'Buscar'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _clearSearch,
                        icon: const Icon(Icons.clear),
                        label: const Text('Limpiar'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.errorLight,
                    ),
                  ),
                ),
              Expanded(
                child:
                    _results.isEmpty
                        ? Center(
                          child: Text(
                            _isLoading
                                ? ''
                                : 'Ingresa un documento para buscar participantes.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                        : ListView.separated(
                          itemCount: _results.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _results[index];
                            final statusColor = _ticketStatusColor(
                              item.ticketStatus,
                            );

                            return Material(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => EditParticipantPage(
                                            participant: item.toParticipant(),
                                            event: item.toEvent(),
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.eventName,
                                                  style:
                                                      theme
                                                          .textTheme
                                                          .titleLarge,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  item.participantName,
                                                  style:
                                                      theme
                                                          .textTheme
                                                          .bodyMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(
                                                alpha: 0.16,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              _ticketStatusLabel(
                                                item.ticketStatus,
                                              ),
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                    color: statusColor,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _InfoRow(
                                        icon:
                                            Icons.confirmation_number_outlined,
                                        label:
                                            item.ticketName.isEmpty
                                                ? 'Ticket sin nombre'
                                                : item.ticketName,
                                        secondary: item.categoryName,
                                      ),
                                      const SizedBox(height: 8),
                                      _InfoRow(
                                        icon: Icons.event_outlined,
                                        label: _formatDate(item.eventDate),
                                        secondary: item.eventLocation,
                                      ),
                                      const SizedBox(height: 8),
                                      _InfoRow(
                                        icon: Icons.badge_outlined,
                                        label: item.documentNumber,
                                        secondary: item.validationCode,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String secondary;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium),
              if (secondary.isNotEmpty)
                Text(
                  secondary,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
