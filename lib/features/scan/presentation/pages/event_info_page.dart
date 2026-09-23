import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection_container.dart';
import '../../../event/domain/entities/event_info.dart';
import '../../../event/presentation/bloc/event_info_cubit.dart';
import '../../../event/presentation/bloc/event_info_state.dart';

class EventInfoPage extends StatelessWidget {
  final String eventId;

  const EventInfoPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventInfoCubit(getEventInfo: sl(), eventId: eventId)..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Acerca del evento')),
        body: BlocBuilder<EventInfoCubit, EventInfoState>(
          builder: (context, state) => switch (state) {
            EventInfoLoading() => const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            EventInfoLoaded(:final event) => _EventDetails(event: event),
            EventInfoNotFound() => EmptyState(
                icon: Icons.event_busy_rounded,
                title: 'No encontramos el evento',
                message: 'Creá el documento events/$eventId en Firestore con los campos '
                    'name, date y capacity.',
              ),
            EventInfoError(:final message) => EmptyState(
                icon: Icons.cloud_off_rounded,
                iconColor: AppColors.danger,
                title: 'Sin conexión',
                message: message,
                action: SizedBox(
                  width: 200,
                  child: PrimaryButton(
                    label: 'Reintentar',
                    onPressed: () => context.read<EventInfoCubit>().load(),
                  ),
                ),
              ),
          },
        ),
      ),
    );
  }
}

class _EventDetails extends StatelessWidget {
  final EventInfo event;

  const _EventDetails({required this.event});

  @override
  Widget build(BuildContext context) {
    final date = event.date;
    final capacity = event.capacity;
    final rows = [
      if (date != null) (Icons.calendar_today_rounded, 'Fecha', formatLongDate(date)),
      if (capacity != null) (Icons.groups_rounded, 'Capacidad', '$capacity personas'),
      (Icons.tag_rounded, 'ID del evento', event.id),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        FadeSlideIn(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 24),
            child: Text(event.name, style: Theme.of(context).textTheme.headlineMedium),
          ),
        ),
        FadeSlideIn(
          index: 1,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (final (index, (icon, label, value)) in rows.indexed) ...[
                  if (index > 0) const Divider(indent: 58),
                  _DetailRow(icon: icon, label: label, value: value),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textTertiary),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
