# Pakola Waters — Monorepo

Water Delivery Management System built with Flutter + Firebase.

## Structure

```
pakola_waters/           # Single Flutter project for all 4 apps
  lib/app/
    customer_app/        # Customer mobile entrypoint
    driver_app/          # Driver mobile entrypoint
    supervisor_app/      # Supervisor mobile entrypoint
    admin_web/           # Admin web entrypoint

packages/
  core/                  # Errors, result types, logging, environment
  design_system/         # Light/dark Material 3 theme, colors, spacing
  l10n/                  # English + Urdu ARB localization
  firebase/              # Firebase SDK wrappers
  authentication/        # Auth provider, login screen, routes
  models/                # Shared data models
  repositories/          # Repository layer
  services/              # Service layer
  shared_widgets/        # Snackbars, loading/error/empty views
  utilities/             # Validators, formatters, extensions
```

## Getting Started

```bash
# Install Melos
dart pub global activate melos

# Bootstrap all packages
melos bootstrap

# Run an app (from pakola_waters/)
cd pakola_waters
flutter run -t lib/app/customer_app/main.dart
flutter run -t lib/app/driver_app/main.dart
flutter run -t lib/app/supervisor_app/main.dart
flutter run -t lib/app/admin_web/main.dart -d chrome
```

## Architecture

- **State management:** Provider (`ChangeNotifier`)
- **Routing:** GoRouter with auth redirects
- **Theming:** Light/dark via `AppTheme` (`ThemeMode.system`)
- **Localization:** `packages/l10n` (English + Urdu ARB)
- **Responsive:** `flutter_screenutil` (design size 375×812)
- **Layers:** Presentation → Repositories → Services → Firebase

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/PROJECT_STATUS.md](docs/PROJECT_STATUS.md).
