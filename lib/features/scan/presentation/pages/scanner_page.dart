import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../core/widgets/pressable.dart';
import '../bloc/scan_cubit.dart';
import '../bloc/scan_state.dart';
import '../widgets/scan_drawer.dart';
import '../widgets/scan_error_card.dart';
import '../widgets/scan_frame_overlay.dart';
import '../widgets/scan_result_card.dart';
import '../widgets/scan_status_style.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Pauses the camera while another page is on top, so it neither drains
  /// the battery nor validates tickets the operator can't see.
  Future<void> _openPage(WidgetBuilder builder) async {
    final navigator = Navigator.of(context);
    await _controller.stop();
    await navigator.push(MaterialPageRoute(builder: builder));
    if (mounted) await _controller.start();
  }

  /// Haptics fire together with the card so sight and touch agree. A
  /// rejected entry gets a heavier pulse so it can't be mistaken for a
  /// valid one without looking.
  void _playHaptics(ScanState state) {
    switch (state) {
      case ScanResultReady(:final result) when result.isValid:
        HapticFeedback.mediumImpact();
      case ScanResultReady() || ScanError():
        HapticFeedback.heavyImpact();
      default:
        break;
    }
  }

  Color _frameColor(ScanState state) => switch (state) {
        ScanIdle() => Colors.white,
        ScanLoading() => AppColors.accent,
        ScanResultReady(:final result) => ScanStatusStyle.of(result.type).color,
        ScanError() => AppColors.danger,
        _ => Colors.white,
      };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScanCubit>();

    return Scaffold(
      backgroundColor: Colors.black,
      drawer: ScanDrawer(eventId: cubit.eventId, onNavigate: _openPage),
      body: BlocConsumer<ScanCubit, ScanState>(
        listener: (context, state) => _playHaptics(state),
        builder: (context, state) {
          final showingCard = state is ScanResultReady || state is ScanError;

          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  final rawValue = capture.barcodes.firstOrNull?.rawValue;
                  if (rawValue != null) cubit.onQrDetected(rawValue);
                },
              ),
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: _frameColor(state)),
                duration: AppMotion.fast,
                curve: Curves.ease,
                builder: (context, color, _) => ScanFrameOverlay(accentColor: color ?? Colors.white),
              ),
              _TopBar(controller: _controller),
              _ScanHint(loading: state is ScanLoading, hidden: showingCard),
              if (state is ScanResultReady)
                ScanResultCard(
                  key: ObjectKey(state),
                  result: state.result,
                  onDismissed: cubit.resetToIdle,
                ),
              if (state is ScanError)
                ScanErrorCard(
                  key: ObjectKey(state),
                  message: state.message,
                  onDismissed: cubit.resetToIdle,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final MobileScannerController controller;

  const _TopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              _GlassIconButton(
                icon: Icons.menu_rounded,
                tooltip: 'Menú',
                onTap: () => Scaffold.of(context).openDrawer(),
              ),
              const Spacer(),
              const GlassSurface(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'Escanear entrada',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Spacer(),
              ValueListenableBuilder<MobileScannerState>(
                valueListenable: controller,
                builder: (context, scannerState, _) {
                  final torchOn = scannerState.torchState == TorchState.on;
                  return _GlassIconButton(
                    icon: torchOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
                    tooltip: 'Linterna',
                    active: torchOn,
                    onTap: scannerState.torchState == TorchState.unavailable ? null : controller.toggleTorch,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool active;

  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        pressedScale: 0.92,
        onTap: onTap,
        child: GlassSurface(
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: Curves.ease,
            width: 44,
            height: 44,
            color: active ? AppColors.textPrimary : Colors.transparent,
            child: Icon(
              icon,
              size: 22,
              color: active ? AppColors.background : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanHint extends StatelessWidget {
  final bool loading;
  final bool hidden;

  const _ScanHint({required this.loading, required this.hidden});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: AnimatedOpacity(
            opacity: hidden ? 0 : 1,
            duration: AppMotion.fast,
            curve: Curves.ease,
            child: Center(
              child: GlassSurface(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                // Same footprint for both messages, so swapping them is a
                // quick crossfade in place rather than a jump.
                child: AnimatedSwitcher(
                  duration: AppMotion.fast,
                  switchInCurve: Curves.ease,
                  switchOutCurve: Curves.ease,
                  child: loading
                      ? const _HintContent(key: ValueKey('loading'), text: 'Validando…', loading: true)
                      : const _HintContent(key: ValueKey('idle'), text: 'Apuntá el código QR dentro del marco'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HintContent extends StatelessWidget {
  final String text;
  final bool loading;

  const _HintContent({super.key, required this.text, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loading) ...[
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 10),
        ],
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
