# Project Status

> **Living document** — updated after every meaningful change to the repository.
>
> Last updated: **2026-07-13**

---

## Quick Summary

| Item | Status |
|------|--------|
| **Phase** | Architecture & design |
| **Implementation** | Not started |
| **Active branch** | `cursor/water-delivery-architecture-97fc` |
| **Open PR** | [#1 — Production Architecture Design](https://github.com/AliBatt/pakola_water/pull/1) |

---

## Current State

### What exists today

```
water_delivery/
├── README.md                    ✅ Project overview
├── melos.yaml                   ✅ Monorepo config (no packages yet)
├── analysis_options.yaml        ✅ Shared lint rules
└── docs/
    ├── ARCHITECTURE.md          ✅ Full system architecture
    ├── folder-structure.md      ✅ Monorepo + package layout
    ├── firestore-schema.md      ✅ Collections, indexes, security rules
    ├── diagrams.md              ✅ Auth, data flow, notification diagrams
    └── PROJECT_STATUS.md        ✅ This file
```

### What does NOT exist yet

| Area | Status |
|------|--------|
| `apps/` (4 Flutter apps) | ❌ Not scaffolded |
| `packages/` (shared packages) | ❌ Not scaffolded |
| `functions/` (Cloud Functions) | ❌ Not scaffolded |
| `firebase/` (rules, indexes, hosting) | ❌ Not scaffolded |
| Firebase projects (dev/staging/prod) | ❌ Not configured |
| CI/CD pipelines | ❌ Not configured |
| Tests | ❌ None |

---

## Completed Work

### 2026-07-13 — Architecture design (PR #1)

- [x] Monorepo strategy defined (Melos, `apps/` + `packages/`)
- [x] Clean Architecture layers documented (domain → data → firebase → presentation)
- [x] Firestore schema designed (15 collections + archive)
- [x] Data-driven RBAC with roles, permissions, and custom claims
- [x] Cloud Functions v2 folder structure and function catalog
- [x] Push notification architecture (server-driven via Functions)
- [x] GoRouter routing strategy with auth/role/permission guards
- [x] Riverpod recommended for DI + state management
- [x] Centralized error handling and logging design
- [x] Multi-environment strategy (dev / staging / prod)
- [x] Firestore security rules outline
- [x] Admin web feature module breakdown
- [x] Scalability strategy (→ 10k users, 50 branches, 10k+ orders/day)
- [x] Recommended packages, naming conventions, best practices
- [x] Project status tracking document (this file)

---

## Architecture Decisions (Locked)

These decisions are documented and should not change without an ADR:

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Repository layout | Melos monorepo | Code sharing across 4 apps, atomic changes |
| Architecture pattern | Clean Architecture | Testable, scalable, separation of concerns |
| State management | Riverpod | Compile-safe DI, async patterns, test overrides |
| Routing | GoRouter | Declarative, deep links, route guards |
| Authorization | Data-driven RBAC in Firestore | No hardcoded permissions, admin-manageable roles |
| Complex writes | Cloud Functions callables | Server validation, inventory, notifications |
| Offline | None | Firestore is source of truth, always-online |
| Environments | 3 Firebase projects | dev, staging, prod isolation |

---

## Next Steps

Work through these in order. Each phase should end with an update to this document.

### Phase 1 — Repository scaffolding

- [ ] Install Melos and bootstrap workspace
- [ ] Create `packages/core` with errors, logging, result types
- [ ] Create `packages/domain` with base entities and enums
- [ ] Create `packages/firebase` with service interfaces
- [ ] Create `packages/data` with repository skeletons
- [ ] Create `packages/auth`, `packages/routing`, `packages/ui_kit`, `packages/notifications`
- [ ] Scaffold `apps/customer_app` (empty shell)
- [ ] Scaffold `apps/driver_app` (empty shell)
- [ ] Scaffold `apps/supervisor_app` (empty shell)
- [ ] Scaffold `apps/admin_web` (empty shell)
- [ ] Verify `melos bootstrap`, `melos analyze` pass

### Phase 2 — Firebase setup

- [ ] Create Firebase projects: `water-delivery-dev`, `water-delivery-staging`, `water-delivery-prod`
- [ ] Run `flutterfire configure` for each app × each environment
- [ ] Add `firebase/` directory with `firebase.json`, `.firebaserc`
- [ ] Deploy initial Firestore security rules (deny-all baseline)
- [ ] Deploy Firestore composite indexes
- [ ] Enable Firebase App Check
- [ ] Set up Firebase emulators for local development

### Phase 3 — Authentication & RBAC

- [ ] Implement `AuthService` and `UserSessionService`
- [ ] Implement login / logout / password reset screens
- [ ] Create Cloud Function: `onUserCreate` (create `users/{uid}` doc)
- [ ] Create Cloud Function: `setCustomClaims` (role + branch + permissions on token)
- [ ] Seed system roles: `customer`, `driver`, `supervisor`, `admin`
- [ ] Seed permissions registry
- [ ] Implement `PermissionService` and route guards
- [ ] Wire GoRouter redirect logic per app
- [ ] Test auth flow end-to-end on dev environment

### Phase 4 — Core domain & Cloud Functions

- [ ] Implement order entity, enums, repository interface, use cases
- [ ] Implement `createOrder` Cloud Function (transaction: order + inventory + audit)
- [ ] Implement `assignDriver` Cloud Function
- [ ] Implement `updateOrderStatus` Cloud Function
- [ ] Implement `updateInventory` Cloud Function
- [ ] Implement `sendPushNotification` + `registerFcmToken`
- [ ] Implement `onOrderWrite` trigger (denormalization)
- [ ] Deploy functions to dev

### Phase 5 — Customer app (MVP)

- [ ] Product catalog screen
- [ ] Create order flow
- [ ] Order history + detail
- [ ] Order status tracking (real-time)
- [ ] Push notification handling + deep links
- [ ] Profile management

### Phase 6 — Supervisor app (MVP)

- [ ] Branch order dashboard (real-time stream)
- [ ] Assign driver flow
- [ ] Inventory view
- [ ] Low-stock alerts
- [ ] Notification inbox

### Phase 7 — Driver app (MVP)

- [ ] Assigned deliveries list
- [ ] Order detail + navigation to address
- [ ] Status update flow (out for delivery → delivered)
- [ ] Push notification handling

### Phase 8 — Admin web (MVP)

- [ ] Dashboard with KPIs
- [ ] Branch management CRUD
- [ ] Orders management (cross-branch)
- [ ] Customer / driver management
- [ ] Product catalog management
- [ ] Inventory adjustments
- [ ] Role management UI
- [ ] Settings
- [ ] Deploy to Firebase Hosting (staging)

### Phase 9 — Hardening & launch prep

- [ ] Firestore security rules — full implementation + tests
- [ ] Crashlytics + Analytics integration
- [ ] Scheduled functions: daily reports, archive, token cleanup
- [ ] CI/CD: analyze, test, build per app on PR
- [ ] Staging UAT
- [ ] Production deployment

---

## Progress Tracker

| Phase | Status | Notes |
|-------|--------|-------|
| 0 — Architecture design | ✅ Complete | PR #1 |
| 1 — Repository scaffolding | ⬜ Not started | |
| 2 — Firebase setup | ⬜ Not started | |
| 3 — Authentication & RBAC | ⬜ Not started | |
| 4 — Core domain & Functions | ⬜ Not started | |
| 5 — Customer app MVP | ⬜ Not started | |
| 6 — Supervisor app MVP | ⬜ Not started | |
| 7 — Driver app MVP | ⬜ Not started | |
| 8 — Admin web MVP | ⬜ Not started | |
| 9 — Hardening & launch | ⬜ Not started | |

**Legend:** ✅ Complete · 🔄 In progress · ⬜ Not started · ⏸️ Blocked

---

## Blockers & Open Questions

| # | Item | Status | Notes |
|---|------|--------|-------|
| 1 | Firebase project naming | Open | Confirm: `water-delivery-dev` etc. or use `pakola_water` prefix? |
| 2 | Payment gateway | Open | Cash-only for MVP, or integrate Stripe from start? |
| 3 | Currency / locale | Open | Default currency (PHP?) and primary timezone |
| 4 | Product images | Open | Needed for MVP? Determines Firebase Storage scope |
| 5 | Google Maps | Open | Driver navigation — Maps SDK or external link? |

---

## Change Log

| Date | Change | Updated by |
|------|--------|------------|
| 2026-07-13 | Initial architecture design completed (PR #1) | Cloud Agent |
| 2026-07-13 | Created project status tracking document | Cloud Agent |

---

## How to Use This Document

1. **After every PR or meaningful commit**, update the relevant sections:
   - Move items from "Next Steps" to "Completed Work"
   - Update the progress tracker table
   - Add an entry to the change log
   - Update "Last updated" date at the top
2. **When a decision changes**, add an ADR in `docs/adr/` and reference it here
3. **When a blocker is resolved**, move it to completed or remove it
