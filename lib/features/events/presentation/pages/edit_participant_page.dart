import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/category_utils.dart';
import '../../../../core/utils/document_formatter.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/participant.dart';
import '../../domain/usecases/get_event_categories.dart';
import '../../domain/usecases/get_event_tickets_detailed.dart';
import '../bloc/participant_bloc.dart';

class EditParticipantPage extends StatefulWidget {
  final Participant participant;
  final Event event;

  const EditParticipantPage({
    super.key,
    required this.participant,
    required this.event,
  });

  @override
  State<EditParticipantPage> createState() => _EditParticipantPageState();
}

class _EditParticipantPageState extends State<EditParticipantPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _documentNumberController;
  late TextEditingController _birthDateController;
  
  String? _selectedGender;
  String? _selectedCategoryId;
  String? _selectedTicketId;
  String? _selectedDocumentType;

  List<dynamic> _allCategories = [];
  List<dynamic> _categories = [];
  List<dynamic> _tickets = [];
  bool _isLoadingData = true;
  bool _isAdmin = false;
  bool _isCategorizable = false;
  bool _categoriesEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.participant.firstName);
    _lastNameController = TextEditingController(text: widget.participant.lastName);
    _emailController = TextEditingController(text: widget.participant.email);
    _phoneController = TextEditingController(text: widget.participant.phone);
    _documentNumberController = TextEditingController(text: widget.participant.participantDocumentNumber);
    
    if (_selectedDocumentType == 'rut') {
      final cleanDoc = DocumentFormatter.cleanDocument(_documentNumberController.text);
      if (DocumentFormatter.validateRut(cleanDoc)) {
        _documentNumberController.text = DocumentFormatter.formatRut(cleanDoc);
      }
    }
    
    String initialBirthDate = widget.participant.birthDate ?? '';
    if (initialBirthDate.isNotEmpty) {
      try {
        final parsed = DateTime.parse(initialBirthDate);
        initialBirthDate = DateFormat('dd-MM-yyyy').format(parsed);
      } catch (_) {}
    }
    _birthDateController = TextEditingController(text: initialBirthDate);
    
    _selectedGender = widget.participant.gender;
    _selectedCategoryId = widget.participant.categoryId;
    _selectedTicketId = widget.participant.ticketId;
    _selectedDocumentType = widget.participant.participantDocumentType.toLowerCase();
    if (_selectedDocumentType == 'passport') _selectedDocumentType = 'pasaporte';

    if (!['rut', 'pasaporte'].contains(_selectedDocumentType)) {
      _selectedDocumentType = 'rut';
    }

    _loadData();
  }

  void _updateFilteredCategories() {
    DateTime? birthDate;
    if (_birthDateController.text.isNotEmpty) {
      try {
        birthDate = DateFormat('dd-MM-yyyy').parse(_birthDateController.text);
      } catch (_) {}
    }

    final currentTicket = _tickets.isNotEmpty 
        ? _tickets.firstWhere(
            (t) => t['id']?.toString() == _selectedTicketId?.toString(),
            orElse: () => null,
          )
        : null;

    _isCategorizable = currentTicket?['isCategorizable'] ?? false;

    final bool hasBirthDate = birthDate != null;
    final bool hasGender = _selectedGender != null && _selectedGender!.isNotEmpty;
    _categoriesEnabled = hasBirthDate && hasGender;

    if (!_isCategorizable) {
      AppLogger.info('[EditParticipant] Ticket NO categorizable');
      if (mounted) {
        setState(() {
          _categories = [];
          _categoriesEnabled = false;
        });
      }
      return;
    }

    if (!_categoriesEnabled) {
      AppLogger.info('[EditParticipant] Faltan datos: hasBirthDate=$hasBirthDate, hasGender=$hasGender');
      if (mounted) {
        setState(() {
          _categories = [];
          _categoriesEnabled = false;
        });
      }
      return;
    }

    final filtered = _allCategories.where((cat) {
      final categoryGenders = cat['genders'];
      if (categoryGenders is List) {
        final genderValid = categoryGenders.any((g) => g.toString().toLowerCase() == _selectedGender?.toLowerCase());
        if (!genderValid) return false;
      }

      final categorizationType = cat['categorizationType'] ?? 'age';
      final from = cat['from'] ?? 0;
      final to = cat['to'] ?? 999;

      final age = CategoryUtils.calculateAge(birthDate, widget.event.startDate);
      if (categorizationType == 'age' && age != null) {
        return age >= from && age <= to;
      }

      return true;
    }).toList();

    AppLogger.info('[EditParticipant] Categorías filtradas: ${filtered.length}');

    if (mounted) {
      setState(() {
        _categories = filtered;
        if (_selectedCategoryId != null &&
            !filtered.any((cat) => cat['id'] == _selectedCategoryId)) {
          _selectedCategoryId = null;
        }
      });
    }
  }

  Future<void> _loadData() async {
    final token = await AuthService.getAccessToken() ?? '';
    final userData = await AuthService.getUserData();
    _isAdmin = userData?['role'] == 'admin';

    AppLogger.info('[EditParticipant] Cargando datos para evento: ${widget.event.id}');
    AppLogger.info('[EditParticipant] Ticket ID del participante: $_selectedTicketId');

    final ticketsResult = await context.read<GetEventTicketsDetailed>().execute(widget.event.id, token, _isAdmin);

    final List<dynamic> categoriesByTicket = [];
    if (_selectedTicketId != null) {
      final catResult = await context.read<GetEventCategoriesByTicket>().execute(
        widget.event.id,
        _selectedTicketId!,
        token,
      );
      catResult.fold((l) {
        AppLogger.error('[EditParticipant] Error cargando categorías por ticket: ${l.message}');
      }, (r) {
        categoriesByTicket.addAll(r);
        AppLogger.info('[EditParticipant] Categorías por ticket (${categoriesByTicket.length}): ${categoriesByTicket.map((c) => c['name']).join(', ')}');
      });
    }

    if (mounted) {
      setState(() {
        ticketsResult.fold((l) {
          AppLogger.error('[EditParticipant] Error cargando tickets: ${l.message}');
        }, (r) {
          _tickets = r;
          AppLogger.info('[EditParticipant] Se cargaron ${_tickets.length} tickets.');
          for (var t in _tickets) {
            AppLogger.info(' - TICKET: ${t['name']}, ID: ${t['id']}, isCategorizable: ${t['isCategorizable']}');
          }
        });

        _allCategories = categoriesByTicket;
        AppLogger.info('[EditParticipant] Total categorías para este ticket: ${_allCategories.length}');
        
        _isLoadingData = false;
      });
      _updateFilteredCategories();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _documentNumberController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    DateTime initialDate = DateTime.now().subtract(const Duration(days: 365 * 20));
    if (_birthDateController.text.isNotEmpty) {
      try {
        initialDate = DateFormat('dd-MM-yyyy').parse(_birthDateController.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
      _updateFilteredCategories();
    }
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _documentNumberController.clear();
      _birthDateController.clear();
      _selectedGender = null;
      _selectedCategoryId = null;
      _categories = [];
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String documentNumber = _documentNumberController.text;
      if (_selectedDocumentType == 'rut') {
        final cleanDoc = DocumentFormatter.cleanDocument(documentNumber);
        if (!DocumentFormatter.validateRut(cleanDoc)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('RUT inválido'), backgroundColor: AppColors.error),
          );
          return;
        }
        documentNumber = cleanDoc;
      }
      
      final token = await AuthService.getAccessToken() ?? '';
      
      String birthDateBackend = '';
      if (_birthDateController.text.isNotEmpty) {
        try {
          final parsed = DateFormat('dd-MM-yyyy').parse(_birthDateController.text);
          birthDateBackend = DateFormat('yyyy-MM-dd').format(parsed);
        } catch (_) {
          birthDateBackend = _birthDateController.text;
        }
      }

      final data = {
        'name': _nameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'birthDate': birthDateBackend,
        'documentNumber': documentNumber,
        'documentType': _selectedDocumentType,
        'gender': _selectedGender,
        'ticketId': _selectedTicketId,
        'categoryId': _selectedCategoryId,
        'customFieldValues': [],
      };

      if (mounted) {
        context.read<ParticipantBloc>().add(
          ChangeParticipantEvent(
            orderId: widget.participant.orderId ?? '',
            participantId: widget.participant.validationCode ?? '',
            token: token,
            data: data,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParticipantBloc, ParticipantState>(
      listener: (context, state) {
        if (state is ChangeParticipantSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Participante actualizado exitosamente'), backgroundColor: AppColors.success),
          );
          Navigator.of(context).pop(true);
        } else if (state is ParticipantError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Participante'),
          backgroundColor: AppColors.background,
        ),
        body: _isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.padding),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Información Personal'),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: _buildInputDecoration('Nombre', Icons.person_outline),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _lastNameController,
                              decoration: _buildInputDecoration('Apellido', Icons.person_outline),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedDocumentType,
                                    isExpanded: true,
                                    decoration: _buildInputDecoration('Tipo', Icons.badge_outlined),
                                    items: const [
                                      DropdownMenuItem(value: 'rut', child: Text('RUT')),
                                      DropdownMenuItem(value: 'pasaporte', child: Text('PASAPORTE')),
                                    ],
                                    onChanged: (v) => setState(() => _selectedDocumentType = v),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _documentNumberController,
                                    decoration: _buildInputDecoration('Documento', Icons.numbers),
                                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: _buildInputDecoration('Email', Icons.email_outlined),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              decoration: _buildInputDecoration('Teléfono', Icons.phone_outlined),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _birthDateController,
                                    readOnly: true,
                                    onTap: _selectBirthDate,
                                    decoration: _buildInputDecoration('Fecha Nacimiento', Icons.calendar_today_outlined),
                                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedGender,
                                    isExpanded: true,
                                    decoration: _buildInputDecoration('Género', Icons.people_outline),
                                    items: const [
                                      DropdownMenuItem(value: 'male', child: Text('Masculino')),
                                      DropdownMenuItem(value: 'female', child: Text('Femenino')),
                                    ],
                                    onChanged: (v) {
                                      setState(() => _selectedGender = v);
                                      _updateFilteredCategories();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Información Reserva'),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: widget.participant.validationCode ?? 'Sin código',
                              readOnly: true,
                              decoration: _buildInputDecoration('Código de Validación', Icons.confirmation_number_outlined),
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Ticket y Categoría'),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: widget.participant.ticketName,
                              readOnly: true,
                              decoration: _buildInputDecoration('Ticket', Icons.confirmation_number_outlined),
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            if (_isCategorizable) ...[
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedCategoryId,
                                isExpanded: true,
                                decoration: _buildInputDecoration('Categoría', Icons.category_outlined),
                                items: _categories
                                    .map((e) => DropdownMenuItem<String>(
                                          value: e['id'],
                                          child: Text(e['name'] ?? ''),
                                        ))
                                    .toList(),
                                onChanged: _categoriesEnabled
                                    ? (v) => setState(() => _selectedCategoryId = v)
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.padding),
                    child: BlocBuilder<ParticipantBloc, ParticipantState>(
                      builder: (context, state) {
                        final isLoading = state is ChangeParticipantLoading;
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(color: AppColors.white)
                                    : const Text('GUARDAR CAMBIOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton(
                                onPressed: isLoading ? null : _clearForm,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('LIMPIAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      filled: true,
      fillColor: AppColors.surface,
    );
  }
}