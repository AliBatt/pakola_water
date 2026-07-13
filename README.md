# Water Delivery Management System

Multi-app Flutter + Firebase monorepo for water delivery operations.

## Applications

| App | Platform | Users |
|-----|----------|-------|
| `customer_app` | iOS / Android | Customers placing orders |
| `driver_app` | iOS / Android | Delivery drivers |
| `supervisor_app` | iOS / Android | Branch supervisors |
| `admin_web` | Web (Firebase Hosting) | Global administrators |

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the complete production architecture design.

| Document | Description |
|----------|-------------|
| [Architecture Overview](docs/ARCHITECTURE.md) | Clean Architecture, RBAC, state management, security |
| [Folder Structure](docs/folder-structure.md) | Complete monorepo layout |
| [Firestore Schema](docs/firestore-schema.md) | Collections, fields, indexes, security rules |
| [Diagrams](docs/diagrams.md) | Auth, data flow, notifications, dependency graphs |

## Tech Stack

- **Flutter** (latest stable) · Material 3 · Riverpod · GoRouter
- **Firebase** Auth · Firestore · Cloud Functions v2 · FCM · Hosting
- **Monorepo** managed with Melos

## Status

Architecture design phase — implementation not yet started.
