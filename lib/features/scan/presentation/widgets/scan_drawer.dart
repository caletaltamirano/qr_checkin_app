import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pressable.dart';
import '../pages/event_info_page.dart';
import '../pages/scan_history_page.dart';
import '../pages/sync_tickets_page.dart';

/// Side menu of the scanner. Items don't stagger in: the drawer is opened
/// many times per shift, and a cascade would only make it feel slower.
class ScanDrawer extends StatelessWidget {
  final String eventId;

  /// Opens a page on top of the scanner. The scanner owns navigation so it
  /// can pause the camera while the page is visible.
  final void Function(WidgetBuilder pageBuilder) onNavigate;

  const ScanDrawer({super.key, required this.eventId, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    void open(WidgetBuilder builder) {
      Navigator.of(context).pop();
      onNavigate(builder);
    }

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(eventId: eventId),
              const SizedBox(height: 28),
              _DrawerItem(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Escanear',
                selected: true,
                // Already on the scanner, so just close the drawer.
                onTap: () => Navigator.of(context).pop(),
              ),
              _DrawerItem(
                icon: Icons.history_rounded,
                label: 'Historial de escaneos',
                onTap: () => open((_) => ScanHistoryPage(eventId: eventId)),
              ),
              _DrawerItem(
                icon: Icons.sync_rounded,
                label: 'Sincronizar tickets',
                onTap: () => open((_) => SyncTicketsPage(eventId: eventId)),
              ),
              _DrawerItem(
                icon: Icons.info_outline_rounded,
                label: 'Acerca del evento',
                onTap: () => open((_) => EventInfoPage(eventId: eventId)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String eventId;

  const _Header({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.qr_code_2_rounded, color: AppColors.accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('QR Check-in', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  eventId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.textPrimary : AppColors.textSecondary;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 52,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceRaised : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: selected ? AppColors.accent : color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
