import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection_container.dart';
import '../bloc/sync_cubit.dart';
import '../bloc/sync_state.dart';

class SyncTicketsPage extends StatelessWidget {
  final String eventId;

  const SyncTicketsPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SyncCubit(
        syncTickets: sl(),
        getCachedTicketCount: sl(),
        eventId: eventId,
      )..loadCachedCount(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Sincronizar tickets')),
        body: SafeArea(
          top: false,
          child: BlocBuilder<SyncCubit, SyncState>(
            builder: (context, state) {
              final syncing = state is SyncInProgress;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlideIn(child: _OfflineCountCard(count: state.cachedCount)),
                    const SizedBox(height: 12),
                    FadeSlideIn(index: 1, child: _StatusCard(state: state)),
                    const Spacer(),
                    FadeSlideIn(
                      index: 2,
                      child: PrimaryButton(
                        label: syncing ? 'Sincronizando…' : 'Sincronizar ahora',
                        icon: Icons.sync_rounded,
                        onPressed: syncing ? null : () => context.read<SyncCubit>().sync(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OfflineCountCard extends StatelessWidget {
  final int? count;

  const _OfflineCountCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DISPONIBLES SIN CONEXIÓN', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 10),
          // Crossfade the number when it changes after a sync, so the new
          // value registers as an update rather than a flicker.
          AnimatedSwitcher(
            duration: AppMotion.fast,
            switchInCurve: Curves.ease,
            switchOutCurve: Curves.ease,
            child: Text(
              count == null ? '—' : '$count',
              key: ValueKey(count),
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.2,
                height: 1,
                color: AppColors.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'tickets guardados en este dispositivo para escanear sin internet.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final SyncState state;

  const _StatusCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final (icon, color, title, message) = switch (state) {
      SyncIdle() => (
          Icons.cloud_download_outlined,
          AppColors.textSecondary,
          'Listo para sincronizar',
          'Sube los check-ins hechos sin conexión y descarga todos los tickets del evento.',
        ),
      SyncInProgress() => (
          Icons.sync_rounded,
          AppColors.accent,
          'Sincronizando…',
          'No cierres esta pantalla.',
        ),
      SyncSuccess(:final report, :final syncedAt) => (
          Icons.check_rounded,
          AppColors.success,
          'Sincronizado a las ${formatTime(syncedAt)}',
          '${report.downloaded} tickets descargados · ${report.uploaded} check-ins subidos.',
        ),
      SyncFailure(:final message) => (
          Icons.cloud_off_rounded,
          AppColors.danger,
          'No se pudo sincronizar',
          message,
        ),
    };

    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: Curves.ease,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusIcon(icon: icon, color: color, spinning: state is SyncInProgress),
          const SizedBox(width: 14),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              switchInCurve: Curves.ease,
              switchOutCurve: Curves.ease,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topLeft,
                children: [...previous, ?current],
              ),
              child: Column(
                key: ValueKey(title),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(message, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final bool spinning;

  const _StatusIcon({required this.icon, required this.color, required this.spinning});

  @override
  State<_StatusIcon> createState() => _StatusIconState();
}

class _StatusIconState extends State<_StatusIcon> with SingleTickerProviderStateMixin {
  // Constant motion, so linear: easing would make it pulse on every turn.
  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _syncRotation();
  }

  @override
  void didUpdateWidget(covariant _StatusIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncRotation();
  }

  void _syncRotation() {
    if (widget.spinning && !_rotation.isAnimating) {
      _rotation.repeat();
    } else if (!widget.spinning) {
      _rotation.reset();
    }
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: RotationTransition(
        turns: _rotation,
        child: Icon(widget.icon, size: 22, color: widget.color),
      ),
    );
  }
}
