import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/scan/data/datasources/scan_history_local_datasource.dart';
import 'features/scan/data/datasources/ticket_local_datasource.dart';
import 'features/scan/presentation/pages/scanner_page.dart';
import 'features/scan/presentation/bloc/scan_cubit.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

// TODO: replace with the authenticated operator/event once features/auth
// is implemented (see CLAUDE.md pending step 3).
const _demoEventId = 'demo-event';
const _demoOperatorId = 'demo-operator';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<String>(TicketLocalDataSourceImpl.boxName);
  await Hive.openBox<String>(ScanHistoryLocalDataSourceImpl.boxName);

  // Firebase has no project configured yet (`flutterfire configure` is
  // still pending, see CLAUDE.md). Guard the init so the app keeps
  // running offline-only instead of crashing on startup.
  var firebaseReady = true;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    firebaseReady = false;
  }

  if (firebaseReady) {
    await initDependencies();
  }

  runApp(MyApp(firebaseReady: firebaseReady));
}

class MyApp extends StatelessWidget {
  final bool firebaseReady;

  const MyApp({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Check-in',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: firebaseReady ? _buildScannerHome() : const _FirebaseNotConfiguredPage(),
    );
  }

  Widget _buildScannerHome() {
    return BlocProvider(
      create: (_) => ScanCubit(
        validateTicket: sl(),
        saveScanRecord: sl(),
        eventId: _demoEventId,
        operatorId: _demoOperatorId,
      ),
      child: const ScannerPage(),
    );
  }
}

class _FirebaseNotConfiguredPage extends StatelessWidget {
  const _FirebaseNotConfiguredPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_off_rounded, color: AppColors.warning, size: 36),
              ),
              const SizedBox(height: 24),
              Text(
                'Firebase no está configurado',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Corré "flutterfire configure" para generar firebase_options.dart '
                'y volvé a abrir la app.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
