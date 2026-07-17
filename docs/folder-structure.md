# Complete Folder Structure

Monorepo layout for the Water Delivery Management System.

---

## Root

```
pakola_water/
├── pakola_waters/          # Single Flutter project (all 4 apps)
├── packages/
├── functions/
├── firebase/
├── docs/
├── tools/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml
├── melos.yaml
├── analysis_options.yaml
├── .gitignore
└── README.md
```

---

## Apps (single Flutter project)

All four apps live in one Flutter project with separate entrypoints:

```
pakola_waters/
├── android/
├── ios/
├── web/
├── lib/
│   └── app/
│       ├── customer_app/
│       │   ├── main.dart
│       │   ├── app.dart
│       │   ├── config/
│       │   ├── di/
│       │   ├── routing/
│       │   └── features/
│       ├── driver_app/
│       │   └── … (same layout)
│       ├── supervisor_app/
│       │   └── … (same layout)
│       └── admin_web/
│           └── … (same layout)
├── test/
├── pubspec.yaml
└── README.md
```

Run with:

```bash
flutter run -t lib/app/customer_app/main.dart
flutter run -t lib/app/driver_app/main.dart
flutter run -t lib/app/supervisor_app/main.dart
flutter run -t lib/app/admin_web/main.dart -d chrome
```

---

## Packages

### core

Cross-cutting concerns with zero feature knowledge.

```
packages/core/
├── lib/
│   ├── core.dart                    # Barrel export
│   ├── config/
│   │   ├── app_constants.dart
│   │   └── env_config.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   ├── exceptions.dart
│   │   ├── result.dart
│   │   ├── error_mapper.dart
│   │   └── mappers/
│   │       ├── firebase_auth_error_mapper.dart
│   │       ├── firestore_error_mapper.dart
│   │       ├── cloud_function_error_mapper.dart
│   │       └── network_error_mapper.dart
│   ├── logging/
│   │   ├── app_logger.dart
│   │   ├── log_level.dart
│   │   ├── console_logger.dart
│   │   ├── crashlytics_logger.dart
│   │   └── logger_provider.dart
│   ├── network/
│   │   └── connectivity_service.dart
│   ├── extensions/
│   │   ├── datetime_extensions.dart
│   │   └── string_extensions.dart
│   └── utils/
│       ├── validators.dart
│       └── formatters.dart
├── test/
└── pubspec.yaml
```

**Why:** Single source for errors, logging, constants. No Firebase or UI dependencies.

---

### domain

Pure business logic. Zero external dependencies.

```
packages/domain/
├── lib/
│   ├── domain.dart
│   ├── entities/
│   │   ├── user.dart
│   │   ├── role.dart
│   │   ├── branch.dart
│   │   ├── customer.dart
│   │   ├── driver.dart
│   │   ├── order.dart
│   │   ├── product.dart
│   │   ├── inventory.dart
│   │   ├── payment.dart
│   │   └── notification.dart
│   ├── enums/
│   │   ├── order_status.dart
│   │   ├── payment_status.dart
│   │   ├── user_status.dart
│   │   └── driver_status.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── user_repository.dart
│   │   ├── order_repository.dart
│   │   ├── product_repository.dart
│   │   ├── inventory_repository.dart
│   │   ├── payment_repository.dart
│   │   ├── notification_repository.dart
│   │   ├── branch_repository.dart
│   │   └── settings_repository.dart
│   ├── usecases/
│   │   ├── auth/
│   │   │   ├── sign_in.dart
│   │   │   ├── sign_out.dart
│   │   │   └── get_current_user.dart
│   │   ├── orders/
│   │   │   ├── create_order.dart
│   │   │   ├── get_orders_by_branch.dart
│   │   │   ├── get_customer_orders.dart
│   │   │   ├── get_assigned_orders.dart
│   │   │   ├── assign_driver.dart
│   │   │   └── update_order_status.dart
│   │   ├── inventory/
│   │   │   ├── get_branch_inventory.dart
│   │   │   └── adjust_inventory.dart
│   │   ├── notifications/
│   │   │   ├── get_notifications.dart
│   │   │   └── mark_notification_read.dart
│   │   └── permissions/
│   │       ├── load_permissions.dart
│   │       └── check_permission.dart
│   └── value_objects/
│       ├── order_query.dart
│       ├── pagination.dart
│       └── address.dart
├── test/
└── pubspec.yaml
```

**Why:** Entities and contracts are stable. Changes here ripple intentionally to data + presentation.

---

### data

Repository implementations, DTOs, mappers.

```
packages/data/
├── lib/
│   ├── data.dart
│   ├── models/
│   │   ├── user_dto.dart
│   │   ├── order_dto.dart
│   │   ├── product_dto.dart
│   │   └── ...
│   ├── mappers/
│   │   ├── user_mapper.dart
│   │   ├── order_mapper.dart
│   │   └── ...
│   ├── datasources/
│   │   ├── remote/
│   │   │   ├── auth_remote_datasource.dart
│   │   │   ├── user_remote_datasource.dart
│   │   │   ├── order_remote_datasource.dart
│   │   │   ├── product_remote_datasource.dart
│   │   │   ├── inventory_remote_datasource.dart
│   │   │   └── notification_remote_datasource.dart
│   │   └── local/
│   │       └── (empty — no offline)
│   ├── repositories/
│   │   ├── auth_repository_impl.dart
│   │   ├── user_repository_impl.dart
│   │   ├── order_repository_impl.dart
│   │   └── ...
│   └── di/
│       └── data_providers.dart
├── test/
└── pubspec.yaml
```

**Why:** Isolates serialization and Firebase-specific data access from domain logic.

---

### firebase

Firebase SDK abstraction layer.

```
packages/firebase/
├── lib/
│   ├── firebase.dart
│   ├── config/
│   │   ├── environment.dart
│   │   ├── firebase_options_dev.dart
│   │   ├── firebase_options_staging.dart
│   │   └── firebase_options_prod.dart
│   ├── auth/
│   │   ├── auth_service.dart
│   │   └── auth_exception_mapper.dart
│   ├── firestore/
│   │   ├── firestore_service.dart
│   │   ├── collection_paths.dart
│   │   ├── query_builder.dart
│   │   └── firestore_exception_mapper.dart
│   ├── functions/
│   │   ├── cloud_functions_service.dart
│   │   └── callable_names.dart
│   ├── messaging/
│   │   ├── fcm_service.dart
│   │   ├── token_manager.dart
│   │   └── notification_handler.dart
│   ├── storage/
│   │   └── storage_service.dart
│   ├── session/
│   │   └── user_session_service.dart
│   └── di/
│       └── firebase_providers.dart
├── test/
└── pubspec.yaml
```

**Why:** Single place to swap/mock Firebase. Data layer depends on interfaces, not raw SDK.

---

### auth

Authentication flow, RBAC, session state.

```
packages/auth/
├── lib/
│   ├── auth.dart
│   ├── models/
│   │   ├── user_session.dart
│   │   └── permission_set.dart
│   ├── services/
│   │   ├── auth_flow_service.dart
│   │   └── permission_service.dart
│   ├── providers/
│   │   ├── auth_state_provider.dart
│   │   ├── user_session_provider.dart
│   │   └── permission_provider.dart
│   └── presentation/
│       ├── screens/
│       │   ├── login_screen.dart
│       │   ├── forgot_password_screen.dart
│       │   └── suspended_screen.dart
│       └── widgets/
│           └── login_form.dart
├── test/
└── pubspec.yaml
```

**Why:** Auth is cross-cutting. Shared login UI and session logic across all 4 apps.

---

### routing

GoRouter configuration and guards.

```
packages/routing/
├── lib/
│   ├── routing.dart
│   ├── app_router.dart
│   ├── route_paths.dart
│   ├── app_type.dart
│   ├── guards/
│   │   ├── auth_guard.dart
│   │   ├── role_guard.dart
│   │   └── permission_guard.dart
│   ├── routes/
│   │   ├── auth_routes.dart
│   │   ├── customer_routes.dart
│   │   ├── driver_routes.dart
│   │   ├── supervisor_routes.dart
│   │   └── admin_routes.dart
│   └── deep_links/
│       └── notification_deep_link.dart
├── test/
└── pubspec.yaml
```

**Why:** Route definitions are large. Centralizing guards prevents duplication across apps.

---

### ui_kit

Shared Material 3 design system.

```
packages/ui_kit/
├── lib/
│   ├── ui_kit.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── color_schemes.dart
│   │   └── typography.dart
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── cards/
│   │   ├── inputs/
│   │   ├── loading/
│   │   ├── error_view.dart
│   │   ├── empty_state.dart
│   │   └── status_badge.dart
│   └── layouts/
│       ├── responsive_layout.dart
│       └── scaffold_with_nav.dart
├── test/
└── pubspec.yaml
```

**Why:** Consistent branding across 4 apps. Admin web and mobile share components.

---

### notifications

FCM client-side handling.

```
packages/notifications/
├── lib/
│   ├── notifications.dart
│   ├── providers/
│   │   └── notification_providers.dart
│   └── presentation/
│       ├── screens/
│       │   └── notification_inbox_screen.dart
│       └── widgets/
│           └── notification_tile.dart
├── test/
└── pubspec.yaml
```

---

### Feature Presentation Packages (optional split at scale)

For large features, create dedicated presentation packages:

```
packages/feature_orders/
├── lib/
│   ├── presentation/
│   │   ├── providers/
│   │   ├── screens/
│   │   │   ├── order_list_screen.dart
│   │   │   ├── order_detail_screen.dart
│   │   │   └── create_order_screen.dart
│   │   └── widgets/
│   │       ├── order_card.dart
│   │       └── order_status_chip.dart
│   └── feature_orders.dart
└── pubspec.yaml
```

Start with features inside app-specific folders; extract to packages when sharing across apps (e.g. order detail shown in supervisor + admin).

---

## Firebase Config

```
firebase/
├── firestore.rules
├── firestore.indexes.json
├── storage.rules
├── firebase.json
├── .firebaserc
└── hosting/
    └── admin_web/               # Points to apps/admin_web/build/web
```

---

## Cloud Functions

```
functions/
├── src/
│   ├── index.ts
│   ├── config/
│   │   ├── firebase.ts
│   │   └── constants.ts
│   ├── shared/
│   │   ├── auth/
│   │   │   ├── verifyRole.ts
│   │   │   └── customClaims.ts
│   │   ├── validation/
│   │   │   ├── orderValidator.ts
│   │   │   ├── inventoryValidator.ts
│   │   │   └── schemas.ts
│   │   ├── errors/
│   │   │   └── AppError.ts
│   │   ├── logging/
│   │   │   └── logger.ts
│   │   └── utils/
│   │       ├── denormalize.ts
│   │       ├── orderNumber.ts
│   │       └── pagination.ts
│   ├── orders/
│   │   ├── createOrder.ts
│   │   ├── assignDriver.ts
│   │   ├── updateOrderStatus.ts
│   │   └── onOrderWrite.ts
│   ├── inventory/
│   │   ├── updateInventory.ts
│   │   └── onInventoryLow.ts
│   ├── notifications/
│   │   ├── sendPushNotification.ts
│   │   ├── registerFcmToken.ts
│   │   └── notificationTemplates.ts
│   ├── users/
│   │   ├── onUserCreate.ts
│   │   ├── onUserRoleChange.ts
│   │   └── setCustomClaims.ts
│   ├── payments/
│   │   ├── processPayment.ts
│   │   └── onPaymentComplete.ts
│   └── scheduled/
│       ├── dailyReports.ts
│       ├── archiveOldOrders.ts
│       └── cleanupExpiredTokens.ts
├── test/
│   ├── orders/
│   └── shared/
├── package.json
├── tsconfig.json
└── .eslintrc.js
```

---

## Tools

```
tools/
├── scripts/
│   ├── setup.sh                 # Initial dev environment
│   ├── codegen.sh               # build_runner across packages
│   └── deploy.sh                # Deploy per environment
└── melos/
    └── melos.yaml               # (or at root)
```

---

## Melos Configuration (root)

```yaml
name: water_delivery
packages:
  - apps/**
  - packages/**
```

---

## Folder Purpose Summary

| Folder | Exists Because |
|--------|----------------|
| `apps/` | Thin app shells — platform config, entry points, app-specific assets |
| `packages/core/` | Shared utilities without feature or Firebase coupling |
| `packages/domain/` | Business rules testable without any infrastructure |
| `packages/data/` | Bridges domain contracts to Firebase/data sources |
| `packages/firebase/` | SDK wrappers — swap Firebase without touching data/domain |
| `packages/auth/` | Cross-app authentication and RBAC |
| `packages/routing/` | Centralized GoRouter with guards |
| `packages/ui_kit/` | Design system shared across 4 UIs |
| `packages/notifications/` | FCM client handling |
| `functions/` | Server-side validation, triggers, scheduled jobs |
| `firebase/` | Security rules, indexes, hosting config |
| `docs/` | Architecture decisions and schemas |
| `tools/` | Automation scripts |
