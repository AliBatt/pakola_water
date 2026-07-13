# Pakola Waters — Monorepo

Water Delivery Management System built with Flutter + Firebase.

## Structure

```
apps/
  customer_app/      # Customer mobile app
  driver_app/        # Driver mobile app
  supervisor_app/    # Supervisor mobile app
  admin_web/         # Admin web app

packages/
  core/              # Errors, result types, logging, environment
  design_system/     # Material 3 theme
  firebase/          # Firebase SDK wrappers
  authentication/    # Auth provider, login screen, routes
  models/            # Shared data models
  repositories/      # Repository layer
  services/          # Service layer
  shared_widgets/    # Reusable UI widgets
  utilities/         # Validators, formatters, extensions
```

## Getting Started

```bash
# Install Melos
dart pub global activate melos

# Bootstrap all packages
melos bootstrap

# Run an app
cd apps/customer_app && flutter run
cd apps/admin_web && flutter run -d chrome
```

## Architecture

- **State management:** Provider (`ChangeNotifier`)
- **Routing:** GoRouter with auth redirects
- **Layers:** Presentation → Repositories → Services → Firebase

See [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md) and [docs/PROJECT_STATUS.md](../docs/PROJECT_STATUS.md).

## Note

The `pakola_waters/` folder at repo root is the initial Flutter template and can be removed once all apps are verified.
