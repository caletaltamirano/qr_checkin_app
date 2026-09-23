# CLAUDE.md — QR Check-in App

Este archivo documenta el estado actual del proyecto para que Claude Code (u otro agente) pueda continuar el trabajo sin perder contexto.

## Descripción del proyecto

App móvil en Flutter para verificar entradas por QR en un **evento único** (concierto, graduación, etc.). Permite escanear tickets, validarlos contra Firestore, marcarlos como usados, evitar reingresos duplicados, y funcionar en modo offline con sincronización posterior.

- **Nombre del proyecto Flutter:** `qr_checkin_app`
- **Backend:** Firebase (Firestore + Firebase Auth)
- **Cache offline:** Hive
- **State management:** flutter_bloc (Cubit)
- **DI:** get_it
- **Arquitectura:** Clean Architecture (domain / data / presentation), separada por `features/`

## Reglas del proyecto (seguir siempre)

- Código y comentarios en **inglés**, aunque la comunicación con el usuario sea en español.
- Seguir **Clean Architecture** estrictamente: `domain/` no debe importar nada de Flutter, Firebase o paquetes externos — solo entidades y contratos puros.
- Aplicar **SOLID**: interfaces abstractas en `domain/repositories/`, implementaciones concretas en `data/repositories/`, una responsabilidad por clase.
- Convención de nombres: archivos en `snake_case.dart`, clases en `PascalCase`.
- Un archivo = una clase principal (excepto datasources, donde la interfaz + implementación conviven en el mismo archivo por brevedad).
- No agregar información, subtítulos decorativos ni features no solicitadas — ir directo a lo pedido.

## Estado actual — completado ✅

### Estructura de carpetas
Ya creada la estructura completa de Clean Architecture para `features/auth/` (vacía, sin implementar aún) y `features/scan/` (implementada).

### Dependencias instaladas (`pubspec.yaml`)
```
flutter_bloc, equatable, get_it, mobile_scanner, connectivity_plus,
firebase_core, cloud_firestore, firebase_auth,
hive, hive_flutter, path_provider
```

### Feature `scan/` — completa de punta a punta

**domain/**
- `entities/ticket.dart` — entidad `Ticket` con `TicketType` (general/vip/staff) y `TicketStatus` (valid/used/cancelled)
- `entities/scan_result.dart` — entidad `ScanResult` con `ScanResultType` (valid/invalid/alreadyUsed/wrongEvent)
- `repositories/ticket_repository.dart` — interfaz abstracta: `getTicketById`, `validateAndMarkTicket`, `markTicketAsUsed`, `getAllTicketsForEvent`
- `usecases/validate_ticket.dart` — usecase `ValidateTicket`
- `usecases/mark_ticket_as_used.dart` — usecase `MarkTicketAsUsed`

**data/**
- `models/ticket_model.dart` — `TicketModel extends Ticket` con `fromJson`/`toJson`
- `datasources/ticket_remote_datasource.dart` — interfaz + impl con Firestore (`TicketRemoteDataSourceImpl`)
- `datasources/ticket_local_datasource.dart` — interfaz + impl con Hive (`TicketLocalDataSourceImpl`), usa la key del box como id del ticket
- `repositories/ticket_repository_impl.dart` — `TicketRepositoryImpl`: decide online/offline vía `connectivity_plus`, coordina remote + local

**presentation/**
- `bloc/scan_state.dart` — estados: `ScanIdle`, `ScanLoading`, `ScanResultReady`, `ScanError`
- `bloc/scan_cubit.dart` — `ScanCubit` con `onQrDetected(ticketId)` y `resetToIdle()`
- `bloc/scan_history_cubit.dart`, `bloc/sync_cubit.dart` (+ sus states)
- `pages/scanner_page.dart` — cámara + `BlocConsumer`, chrome translúcido, haptics por resultado; pausa la cámara al abrir otra página
- `pages/scan_history_page.dart` — historial local (Hive `scan_history_box`), resumen + lista
- `pages/sync_tickets_page.dart` — `SyncTickets`: sube check-ins offline y descarga/cachea los tickets
- `pages/event_info_page.dart` — lee `events/{eventId}` vía `features/event/`
- `widgets/scan_sheet.dart` — contenedor animado: entra con ease-out fuerte, swipe-down con rubber-band y springs, auto-cierre con barra de cuenta regresiva
- `widgets/scan_result_card.dart`, `widgets/scan_error_card.dart`, `widgets/scan_card_body.dart` — tarjetas sobre `ScanSheet`
- `widgets/scan_drawer.dart` — menú lateral

### `features/event/`
Entidad `EventInfo`, `EventRepository`, `GetEventInfo`, datasource Firestore y `EventInfoCubit`.

### `core/`
Tema oscuro (`theme/app_theme.dart`, `app_colors.dart`), tokens de movimiento (`theme/app_motion.dart`: curva `Cubic(0.23, 1, 0.32, 1)`, duraciones < 300ms) y widgets compartidos (`Pressable`, `GlassSurface`, `PrimaryButton`, `EmptyState`, `FadeSlideIn`). Diseño basado en las skills `emil-design-eng`, `animate` y `apple-design` (`.claude/skills/`).

### DI
- `lib/injection_container.dart` — registra todo con `get_it` (`sl`): Firestore, Connectivity, datasources, repository, usecases

### `main.dart`
Inicializa Hive (`tickets_box`), llama `initDependencies()` y envuelve `Firebase.initializeApp()` en un try/catch: si Firebase no está configurado, muestra una pantalla de aviso en vez de crashear (ver punto 2 de pendientes). `eventId`/`operatorId` están hardcodeados (`demo-event`/`demo-operator`) hasta que exista `features/auth/`.

### Testing
Suite con `mocktail` + `bloc_test` cubriendo usecases, `TicketRepositoryImpl` (online/offline + sync), `ScanCubit` y la tarjeta de resultado con widget tests (32 tests, `flutter test` en verde). `flutter analyze` limpio. `flutter build web` compila de punta a punta — es el target usado para probar la app completa, porque `mobile_scanner` no tiene implementación para Windows desktop (sí para Android/iOS/macOS/web).

### Bugs corregidos en esta sesión
Había varios imports rotos que impedían compilar (`ticket_model.dart`, `ticket_remote_datasource.dart` apuntaban a rutas inexistentes) y `ticket_repository_impl.dart` estaba en `domain/repositories/` en vez de `data/repositories/` (violaba la regla de Clean Architecture del propio archivo). También `pages/` y `widgets/` de `presentation/` estaban anidados dentro de `bloc/` en vez de ser carpetas hermanas — ya corregido, la estructura real ahora coincide con la documentada arriba.

## Pendiente — próximos pasos en orden

1. **Conectar Firebase real** — correr `flutterfire configure` para generar `firebase_options.dart`, crear el proyecto en la consola de Firebase, y agregar `options: DefaultFirebaseOptions.currentPlatform` a `Firebase.initializeApp()` en `main.dart`. Este paso requiere login interactivo de Google/Firebase CLI, así que lo tiene que correr el usuario.
2. **Feature `auth/`** — implementar login de operadores (portero/admin) siguiendo el mismo patrón que `scan/`: entities (`Operator`), repository interface, usecases (`LoginOperator`, `LogoutOperator`), datasource con `firebase_auth`, Cubit, `LoginPage`. Una vez lista, reemplazar los `demo-event`/`demo-operator` hardcodeados en `main.dart`.
3. **Modelo de datos en Firestore** (colecciones a crear):
   ```
   events/{eventId}     — name, date, capacity
   tickets/{ticketId}   — eventId, holderName, type, status, usedAt, usedBy
   operators/{uid}      — name, role: "admin" | "gatekeeper"
   ```
4. **Entrada manual** — UI para buscar/validar ticket por ID cuando el QR falla (reutiliza `ValidateTicket` usecase, ya está listo en el dominio).
5. ~~Sincronización~~ — hecha manualmente desde el drawer (`SyncTicketsPage`). Pendiente: dispararla automáticamente al abrir la app.
6. **Dashboard** (`features/dashboard/`) — contador de aforo en tiempo real, historial de escaneos, exportar CSV/PDF. No iniciado todavía.
7. **Reglas de seguridad de Firestore** — restringir lectura/escritura de `tickets` solo a operadores autenticados con rol válido.

## Notas de contexto

- El usuario (Calet) prefiere avanzar **paso a paso, un archivo a la vez**, con el código listo para copiar y pegar y la ruta exacta indicada.
- Terminal de trabajo: VS Code con PowerShell en Windows.
- Nivel de experiencia: está aprendiendo Clean Architecture y SOLID sobre la marcha, así que las explicaciones de "por qué" de cada decisión son bienvenidas, pero sin alargar innecesariamente.
