import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tocke/core/constants/app_colors.dart';
import 'package:tocke/features/scanner/domain/entities/validation_result.dart';
import 'package:tocke/features/scanner/domain/usecases/check_ticket_status.dart';
import 'package:tocke/features/scanner/domain/usecases/update_ticket_runner_data.dart';
import 'package:tocke/features/scanner/domain/usecases/validate_ticket_qr.dart';
import 'package:tocke/features/scanner/presentation/bloc/scanner_bloc.dart';
import 'package:tocke/features/scanner/presentation/bloc/scanner_event.dart';
import 'package:tocke/features/scanner/presentation/bloc/scanner_state.dart';
import 'package:tocke/features/scanner/presentation/widgets/ticket_status_card.dart';

class TicketConfirmationPage extends StatelessWidget {
  final ValidationResult initialTicket;
  final ScannerBloc? scannerBloc;
  final VoidCallback? onNewScan;
  final Function(String, String)? onSaveData;

  const TicketConfirmationPage({
    super.key,
    required this.initialTicket,
    this.scannerBloc,
    this.onNewScan,
    this.onSaveData,
  });

  @override
  Widget build(BuildContext context) {
    final bloc =
        scannerBloc ??
        ScannerBloc(
          checkTicketStatus: context.read<CheckTicketStatus>(),
          validateTicketQR: context.read<ValidateTicketQR>(),
          updateTicketRunnerData: context.read<UpdateTicketRunnerData>(),
        );

    return BlocProvider.value(
      value: bloc,
      child: _TicketConfirmationView(
        initialTicket: initialTicket,
        onNewScan: onNewScan,
        onSaveData: onSaveData,
      ),
    );
  }
}

class _TicketConfirmationView extends StatefulWidget {
  final ValidationResult initialTicket;
  final VoidCallback? onNewScan;
  final Function(String, String)? onSaveData;

  const _TicketConfirmationView({
    required this.initialTicket,
    this.onNewScan,
    this.onSaveData,
  });

  @override
  State<_TicketConfirmationView> createState() =>
      _TicketConfirmationViewState();
}

class _TicketConfirmationViewState extends State<_TicketConfirmationView> {
  @override
  void initState() {
    super.initState();
    if (widget.initialTicket.validationCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ScannerBloc>().add(
          CheckTicketStatusEvent(widget.initialTicket.validationCode!),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerBloc, ScannerState>(
      listener: (context, state) {
        if (state is ValidationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ticket validado para ${state.result.participantName}',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is RunnerDataSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Datos guardados para ${state.result.participantName}',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is ScannerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<ScannerBloc, ScannerState>(
        builder: (context, state) {
          final isLoading =
              state is CheckingTicketStatus ||
              state is ValidatingTicket ||
              state is SavingRunnerData;

          final currentResult =
              state is TicketStatusLoaded
                  ? state.result
                  : state is ValidationSuccess
                  ? state.result
                  : state is RunnerDataSaved
                  ? state.result
                  : widget.initialTicket;

          if (state is CheckingTicketStatus &&
              currentResult == widget.initialTicket) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          return TicketStatusCard(
            ticket: currentResult,
            runnerNumber: currentResult.runnerNumber ?? '',
            chipId: currentResult.chipId ?? '',
            isFirstTime: currentResult.ticketStatus == 'valid',
            isSaving: isLoading,
            onNewScan: () {
              if (widget.onNewScan != null) {
                widget.onNewScan!();
              } else {
                Navigator.of(context).pop();
              }
            },
            onSaveData: (runnerNumber, chipId) {
              if (widget.onSaveData != null) {
                widget.onSaveData!(runnerNumber, chipId);
              } else {
                final validationCode = currentResult.validationCode ?? '';
                if (validationCode.isNotEmpty) {
                  context.read<ScannerBloc>().add(
                    UpdateRunnerDataEvent(
                      validationCode: validationCode,
                      runnerNumber: runnerNumber,
                      chipId: chipId,
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}
