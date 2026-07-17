# Project Status

> **Living document** — updated after every meaningful change to the repository.
>
> Last updated: **2026-07-17**

---

## Quick Summary

| Item | Status |
|------|--------|
| **Phase** | Monorepo scaffolding (Phase 1) |
| **Implementation** | Basic app shells + shared packages |
| **Active branch** | `cursor/monorepo-scaffold-97fc` |
| **State management** | Provider |
| **Routing** | GoRouter |

---

## Current State

### What exists today

```
pakola_water/
├── pakola_waters/           ✅ Single Flutter project (all 4 apps)
│   └── lib/app/
│       ├── customer_app/    ✅ Customer mobile shell
│       ├── driver_app/      ✅ Driver mobile shell
│       ├── supervisor_app/  ✅ Supervisor mobile shell
│       └── admin_web/       ✅ Admin web shell
├── packages/
│   ├── core/                ✅ Result, failures, logging, environment
│   ├── design_system/       ✅ Light/dark Material 3 theme, colors, spacing
│   ├── l10n/                ✅ English + Urdu ARB localization
│   ├── firebase/            ✅ Auth/Firestore service wrappers (stub bootstrap)
│   ├── authentication/      ✅ AuthProvider, LoginScreen, auth routes
│   ├── models/              ✅ AppUser, enums (AppRole, OrderStatus, UserStatus)
│   ├── repositories/        ✅ Auth + User repository interfaces/impls
│   ├── services/            ✅ Auth + User services
│   ├── shared_widgets/      ✅ Loading, Error, Empty state widgets
│   └── utilities/           ✅ Validators, formatters, extensions
├── docs/                    ✅ Architecture documentation
├── melos.yaml               ✅ Monorepo workspace config
├── pubspec.yaml             ✅ Workspace root (Melos)
└── README.md                ✅ Updated
```

### Each app folder includes

- `main.dart` — bootstrap with Firebase init + Provider wiring
- `app.dart` — `MaterialApp.router` with shared theme
- `config/app_config.dart` — app name, required role, environment
- `di/app_providers.dart` — dependency injection (Provider)
- `routing/app_router.dart` — GoRouter with auth/role guards
- `features/home/home_screen.dart` — placeholder dashboard

### What does NOT exist yet

| Area | Status |
|------|--------|
| Firebase project configuration | ❌ Need `flutterfire configure` |
| `functions/` (Cloud Functions) | ❌ Not scaffolded |
| `firebase/` (rules, indexes, hosting) | ❌ Not scaffolded |
| Feature modules (orders, inventory, etc.) | ❌ Not started |
| Real authentication flow (Firebase connected) | ❌ Stub only |
| CI/CD pipelines | ❌ Not configured |
| Integration tests | ❌ Placeholder unit tests only |

---

## Completed Work

### 2026-07-13 — Architecture design (PR #1, merged)

- [x] Full architecture documentation in `docs/`
- [x] Firestore schema, security rules outline, diagrams
- [x] Project status tracking document

### 2026-07-13 — Monorepo scaffolding (Phase 1)

- [x] Created 4 Flutter apps under `apps/`
- [x] Created 9 shared packages under `packages/`
- [x] Provider-based DI (`AppProviders`, `AuthProvider`)
- [x] GoRouter with auth redirect + role guard per app
- [x] Shared login screen in `authentication` package
- [x] Layered architecture: apps → repositories → services → firebase
- [x] Melos bootstrap verified (`melos bootstrap`, `melos run analyze` pass)
- [x] Root workspace `pubspec.yaml` for Melos

---

## Architecture Decisions (Locked)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Repository layout | Melos monorepo | Code sharing across 4 apps |
| Architecture pattern | Layered Clean Architecture | UI → Repositories → Services → Firebase |
| State management | **Provider** | Team preference, ChangeNotifier pattern |
| Routing | GoRouter | Auth redirects, role-based routing |
| Authorization | Role per app via `AppConfig.requiredRole` | Customer/Driver/Supervisor/Admin separation |
| Offline | None | Firestore is source of truth |

---

## Next Steps

### Immediate (Phase 1 completion)

- [ ] Run `flutterfire configure` for each app (dev environment)
- [ ] Wire `FirebaseBootstrap.initialize()` with generated options
- [ ] Remove or archive `pakola_waters/` template folder
- [ ] Add `analysis_options.yaml` inheritance to all packages

### Phase 2 — Firebase setup

- [ ] Create Firebase projects (dev / staging / prod)
- [ ] Add `firebase/` directory with rules, indexes, hosting
- [ ] Deploy deny-all baseline security rules
- [ ] Set up Firebase emulators

### Phase 3 — Authentication (working E2E)

- [ ] Seed `roles` and `users` collections
- [ ] Cloud Function: `onUserCreate`, `setCustomClaims`
- [ ] Test login → profile fetch → role redirect per app
- [ ] Add forgot-password screen

### Phase 4 — First feature (Orders)

- [ ] Add order models to `packages/models`
- [ ] Order repository + service
- [ ] Customer: create order screen
- [ ] Supervisor: order list + assign driver
- [ ] Driver: assigned orders list

---

## Progress Tracker

| Phase | Status | Notes |
|-------|--------|-------|
| 0 — Architecture design | ✅ Complete | Merged PR #1 |
| 1 — Repository scaffolding | 🔄 In progress | Apps + packages created |
| 2 — Firebase setup | ⬜ Not started | |
| 3 — Authentication & RBAC | ⬜ Not started | Stub auth exists |
| 4 — Core domain & Functions | ⬜ Not started | |
| 5 — Customer app MVP | ⬜ Not started | |
| 6 — Supervisor app MVP | ⬜ Not started | |
| 7 — Driver app MVP | ⬜ Not started | |
| 8 — Admin web MVP | ⬜ Not started | |
| 9 — Hardening & launch | ⬜ Not started | |

**Legend:** ✅ Complete · 🔄 In progress · ⬜ Not started · ⏸️ Blocked

---

## How to Run

```bash
dart pub global activate melos
melos bootstrap

# Customer app
cd apps/customer_app && flutter run

# Admin web
cd apps/admin_web && flutter run -d chrome
```

---

## Change Log

| Date | Change | Updated by |
|------|--------|------------|
| 2026-07-13 | Initial architecture design completed (PR #1) | Cloud Agent |
| 2026-07-13 | Created project status tracking document | Cloud Agent |
| 2026-07-13 | Scaffolded monorepo: 4 apps + 9 packages with Provider/GoRouter | Cloud Agent |
