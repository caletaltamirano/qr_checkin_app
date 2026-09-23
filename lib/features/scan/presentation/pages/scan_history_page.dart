import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/scan_record.dart';
import '../../domain/entities/scan_result.dart';
import '../bloc/scan_history_cubit.dart';
import '../bloc/scan_history_state.dart';
import '../widgets/scan_status_style.dart';
import '../widgets/ticket_type_chip.dart';

class ScanHistoryPage extends StatelessWidget {
  final String eventId;

  const ScanHistoryPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanHistoryCubit(getScanHistory: sl(), eventId: eventId)..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Historial de escaneos')),
        body: BlocBuilder<ScanHistoryCubit, ScanHistoryState>(
          builder: (context, state) => switch (state) {
            ScanHistoryLoading() => const SizedBox.shrink(),
            ScanHistoryError(:final message) => EmptyState(
                icon: Icons.error_outline_rounded,
                iconColor: AppColors.danger,
                title: 'Algo salió mal',
                message: message,
              ),
            ScanHistoryLoaded(:final records) when records.isEmpty => const EmptyState(
                icon: Icons.history_rounded,
                title: 'Todavía no hay escaneos',
                message: 'Cada ticket que escanees va a aparecer acá, del más reciente al más antiguo.',
              ),
            ScanHistoryLoaded(:final records) => _HistoryList(records: records),
          },
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<ScanRecord> records;

  const _HistoryList({required this.records});

  @override
  Widget build(BuildContext context) {
    final admitted = records.where((r) => r.resultType == ScanResultType.valid).length;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: records.length + 1,
      separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 20 : 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return FadeSlideIn(
            child: _Summary(total: records.length, admitted: admitted),
          );
        }
        return FadeSlideIn(
          index: index,
          child: _HistoryTile(record: records[index - 1]),
        );
      },
    );
  }
}

class _Summary extends StatelessWidget {
  final int total;
  final int admitted;

  const _Summary({required this.total, required this.admitted});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SummaryStat(label: 'ESCANEOS', value: total, color: AppColors.textPrimary)),
        const SizedBox(width: 12),
        Expanded(child: _SummaryStat(label: 'INGRESOS', value: admitted, color: AppColors.success)),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryStat(label: 'RECHAZOS', value: total - admitted, color: AppColors.danger),
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SummaryStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final ScanRecord record;

  const _HistoryTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final style = ScanStatusStyle.of(record.resultType);
    final ticketType = record.ticketType;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, size: 20, color: style.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.holderName ?? record.ticketId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  style.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: style.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatTime(record.scannedAt),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              if (ticketType != null) ...[
                const SizedBox(height: 6),
                TicketTypeChip(type: ticketType),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
