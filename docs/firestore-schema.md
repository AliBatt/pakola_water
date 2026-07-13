# Firestore Database Schema

Complete collection and document structure for the Water Delivery Management System.

---

## Design Principles

1. **Flat top-level collections** with `branchId` for partitioning (not deeply nested subcollections).
2. **Denormalize** display fields on `orders` to avoid N+1 reads.
3. **Immutable audit** via `order_events` and `inventory_transactions`.
4. **Server-authoritative writes** for inventory, payments, and order state transitions.
5. **camelCase** field names throughout.

---

## Collection: `users`

**Path:** `users/{uid}` (uid = Firebase Auth UID)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | yes | Login email |
| `displayName` | string | yes | Full name |
| `phone` | string | no | E.164 format |
| `roleId` | string | yes | Reference to `roles/{roleId}` |
| `branchIds` | string[] | no | Branches user belongs to (driver, supervisor) |
| `primaryBranchId` | string | no | Default branch context |
| `status` | string | yes | `active`, `suspended`, `pending` |
| `fcmTokens` | string[] | no | Managed by Cloud Functions |
| `photoUrl` | string | no | Profile image URL |
| `metadata` | map | no | Extensible key-value |
| `createdAt` | timestamp | yes | |
| `updatedAt` | timestamp | yes | |
| `lastLoginAt` | timestamp | no | |

**Relationships:**
- `roleId` → `roles/{roleId}`
- `branchIds[]` → `branches/{branchId}`
- 1:1 with `customers/{customerId}` where `customerId == uid` (optional pattern)
- 1:1 with `drivers/{driverId}` where `driverId == uid`

---

## Collection: `roles`

**Path:** `roles/{roleId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Machine name: `customer`, `driver`, etc. |
| `displayName` | string | yes | Human-readable |
| `permissions` | string[] | yes | Permission IDs |
| `isSystem` | boolean | yes | Prevents deletion |
| `description` | string | no | |
| `createdAt` | timestamp | yes | |
| `updatedAt` | timestamp | yes | |

**Seed data:** `customer`, `driver`, `supervisor`, `admin` with `isSystem: true`.

---

## Collection: `permissions`

**Path:** `permissions/{permissionId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `resource` | string | yes | `orders`, `inventory`, `users`, etc. |
| `action` | string | yes | `create`, `read`, `update`, `delete` |
| `scope` | string | yes | `own`, `assigned`, `branch`, `all` |
| `description` | string | yes | Admin UI display |

**Permission ID format:** `{resource}.{action}.{scope}`  
Example: `orders.read.branch`, `inventory.update.branch`

---

## Collection: `branches`

**Path:** `branches/{branchId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Branch display name |
| `code` | string | yes | Short code, e.g. `BR01` |
| `address` | map | yes | `{ street, city, state, zip, country, lat, lng }` |
| `phone` | string | no | Branch contact |
| `email` | string | no | Branch email |
| `status` | string | yes | `active`, `inactive` |
| `timezone` | string | yes | IANA timezone, e.g. `Asia/Manila` |
| `operatingHours` | map | no | Per-day hours |
| `deliveryZones` | array | no | Geo zones (future) |
| `managerId` | string | no | Supervisor uid |
| `createdAt` | timestamp | yes | |
| `updatedAt` | timestamp | yes | |

---

## Collection: `customers`

**Path:** `customers/{customerId}` (customerId typically equals user uid)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | string | yes | → `users/{uid}` |
| `branchId` | string | yes | Primary service branch |
| `name` | string | yes | |
| `phone` | string | yes | |
| `email` | string | no | |
| `addresses` | array | yes | `[{ id, label, street, city, lat, lng, isDefault }]` |
| `status` | string | yes | `active`, `suspended` |
| `creditBalance` | number | no | Prepaid balance |
| `notes` | string | no | Internal notes |
| `totalOrders` | number | no | Denormalized counter |
| `createdAt` | timestamp | yes | |
| `updatedAt` | timestamp | yes | |

---

## Collection: `drivers`

**Path:** `drivers/{driverId}` (driverId typically equals user uid)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | string | yes | → `users/{uid}` |
| `branchIds` | string[] | yes | Branches driver serves |
| `name` | string | yes | |
| `phone` | string | yes | |
| `vehicleInfo` | map | no | `{ plateNumber, model, capacity }` |
| `status` | string | yes | `available`, `on_delivery`, `off_duty`, `suspended` |
| `currentLocation` | geopoint | no | Updated by driver app |
| `activeOrderId` | string | no | Current delivery |
| `totalDeliveries` | number | no | Denormalized counter |
| `rating` | number | no | Average rating |
| `createdAt` | timestamp | yes | |
| `updatedAt` | timestamp | yes | |

---

## Collection: `orders`

**Path:** `orders/{orderId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `orderNumber` | string | yes | `{branchCode}-{date}-{seq}` |
| `branchId` | string | yes | |
| `customerId` | string | yes | |
| `customerName` | string | yes | Denormalized |
| `customerPhone` | string | yes | Denormalized |
| `driverId` | string | no | |
| `driverName` | string | no | Denormalized |
| `status` | string | yes | See status enum |
| `lineItems` | array | yes | See line item structure |
| `deliveryAddress` | map | yes | Snapshot at order time |
| `scheduledDate` | timestamp | yes | |
| `scheduledTimeSlot` | string | yes | `morning`, `afternoon`, `evening` |
| `pricing` | map | yes | `{ subtotal, deliveryFee, discount, tax, total }` |
| `paymentStatus` | string | yes | `pending`, `paid`, `refunded` |
| `paymentMethod` | string | no | `cash`, `card`, `credit` |
| `notes` | string | no | Customer notes |
| `internalNotes` | string | no | Staff only |
| `createdBy` | string | yes | uid |
| `version` | number | yes | Optimistic concurrency |
| `createdAt` | timestamp | yes | |
| `updatedAt` | timestamp | yes | |
| `assignedAt` | timestamp | no | |
| `deliveredAt` | timestamp | no | |
| `cancelledAt` | timestamp | no | |
| `cancelledBy` | string | no | |
| `cancelReason` | string | no | |

**Line Item:**

```json
{
  "productId": "string",
  "productName": "string",
  "sku": "string",
  "quantity": 2,
  "unitPrice": 50.00,
  "subtotal": 100.00
}
```

---

## Collection: `order_events`

**Path:** `order_events/{eventId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `orderId` | string | yes | |
| `branchId` | string | yes | For branch-scoped queries |
| `type` | string | yes | `created`, `assigned`, `status_changed`, `cancelled` |
| `fromStatus` | string | no | |
| `toStatus` | string | no | |
| `actorId` | string | yes | uid who performed action |
| `actorRole` | string | yes | |
| `metadata` | map | no | Additional context |
| `createdAt` | timestamp | yes | Immutable |

---

## Collection: `products`

**Path:** `products/{productId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | |
| `sku` | string | yes | Unique stock-keeping unit |
| `description` | string | no | |
| `category` | string | yes | `water`, `dispenser`, `accessory` |
| `unit` | string | yes | `gallon`, `bottle`, `piece` |
| `basePrice` | number | yes | Default price |
| `imageUrl` | string | no | |
| `status` | string | yes | `active`, `discontinued` |
| `branchIds` | string[] | no | Empty = all branches |
| `createdAt` | timestamp | yes | |
| `updatedAt` | timestamp | yes | |

---

## Collection: `inventory`

**Path:** `inventory/{inventoryId}` (inventoryId = `{branchId}_{productId}`)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `branchId` | string | yes | |
| `productId` | string | yes | |
| `productName` | string | yes | Denormalized |
| `sku` | string | yes | Denormalized |
| `quantity` | number | yes | Current stock |
| `reservedQuantity` | number | yes | Reserved by pending orders |
| `availableQuantity` | number | yes | `quantity - reservedQuantity` |
| `lowStockThreshold` | number | yes | Alert threshold |
| `lastRestockedAt` | timestamp | no | |
| `updatedAt` | timestamp | yes | |

---

## Collection: `inventory_transactions`

**Path:** `inventory_transactions/{transactionId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `branchId` | string | yes | |
| `productId` | string | yes | |
| `type` | string | yes | `restock`, `order_deduct`, `adjustment`, `return` |
| `quantityChange` | number | yes | Positive or negative |
| `quantityBefore` | number | yes | |
| `quantityAfter` | number | yes | |
| `orderId` | string | no | If order-related |
| `reason` | string | no | |
| `actorId` | string | yes | |
| `createdAt` | timestamp | yes | Immutable |

---

## Collection: `payments`

**Path:** `payments/{paymentId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `orderId` | string | yes | |
| `customerId` | string | yes | |
| `branchId` | string | yes | |
| `amount` | number | yes | |
| `currency` | string | yes | `PHP`, `USD`, etc. |
| `method` | string | yes | `cash`, `card`, `credit`, `online` |
| `status` | string | yes | `pending`, `completed`, `failed`, `refunded` |
| `transactionRef` | string | no | External payment ref |
| `processedBy` | string | no | uid (driver collects cash) |
| `createdAt` | timestamp | yes | |
| `completedAt` | timestamp | no | |

---

## Collection: `notifications`

**Path:** `notifications/{notificationId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | string | yes | Recipient |
| `type` | string | yes | Event type |
| `title` | string | yes | |
| `body` | string | yes | |
| `data` | map | no | Deep link payload |
| `read` | boolean | yes | Default `false` |
| `createdAt` | timestamp | yes | |

---

## Collection: `settings`

**Path:** `settings/{settingId}`

| Setting IDs:
- `global` — company-wide config
- `branch_{branchId}` — per-branch overrides

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `scope` | string | yes | `global` or `branch` |
| `branchId` | string | no | If branch-scoped |
| `deliveryFees` | map | no | `{ base, perKm }` |
| `timeSlots` | array | no | Available delivery slots |
| `orderLimits` | map | no | `{ maxPerDay, minOrderAmount }` |
| `featureFlags` | map | no | `{ enableCredit: true }` |
| `taxRate` | number | no | |
| `currency` | string | no | |
| `updatedAt` | timestamp | yes | |
| `updatedBy` | string | no | |

---

## Collection: `reports`

**Path:** `reports/{reportId}` (reportId = `{branchId}_{date}_{type}`)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `branchId` | string | yes | |
| `type` | string | yes | `daily`, `weekly`, `monthly` |
| `date` | string | yes | `YYYY-MM-DD` |
| `metrics` | map | yes | `{ totalOrders, revenue, delivered, cancelled }` |
| `generatedAt` | timestamp | yes | |

---

## Collection: `archived_orders`

Same schema as `orders` plus:

| Field | Type | Description |
|-------|------|-------------|
| `archivedAt` | timestamp | When moved to archive |
| `originalOrderId` | string | Reference to original ID |

---

## Composite Indexes

```json
{
  "indexes": [
  {
    "collectionGroup": "orders",
    "fields": [
      { "fieldPath": "branchId", "order": "ASCENDING" },
      { "fieldPath": "status", "order": "ASCENDING" },
      { "fieldPath": "scheduledDate", "order": "DESCENDING" }
    ]
  },
  {
    "collectionGroup": "orders",
    "fields": [
      { "fieldPath": "driverId", "order": "ASCENDING" },
      { "fieldPath": "status", "order": "ASCENDING" },
      { "fieldPath": "scheduledDate", "order": "ASCENDING" }
    ]
  },
  {
    "collectionGroup": "orders",
    "fields": [
      { "fieldPath": "customerId", "order": "ASCENDING" },
      { "fieldPath": "createdAt", "order": "DESCENDING" }
    ]
  },
  {
    "collectionGroup": "orders",
    "fields": [
      { "fieldPath": "branchId", "order": "ASCENDING" },
      { "fieldPath": "createdAt", "order": "DESCENDING" }
    ]
  },
  {
    "collectionGroup": "drivers",
    "fields": [
      { "fieldPath": "branchIds", "arrayConfig": "CONTAINS" },
      { "fieldPath": "status", "order": "ASCENDING" }
    ]
  },
  {
    "collectionGroup": "notifications",
    "fields": [
      { "fieldPath": "userId", "order": "ASCENDING" },
      { "fieldPath": "read", "order": "ASCENDING" },
      { "fieldPath": "createdAt", "order": "DESCENDING" }
    ]
  },
  {
    "collectionGroup": "inventory_transactions",
    "fields": [
      { "fieldPath": "branchId", "order": "ASCENDING" },
      { "fieldPath": "createdAt", "order": "DESCENDING" }
    ]
  },
  {
    "collectionGroup": "payments",
    "fields": [
      { "fieldPath": "customerId", "order": "ASCENDING" },
      { "fieldPath": "createdAt", "order": "DESCENDING" }
    ]
  }
  ]
}
```

---

## Security Rules Outline

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    function role() {
      return request.auth.token.roleId;
    }
    function branchIds() {
      return request.auth.token.branchIds;
    }
    function hasPermission(perm) {
      return perm in request.auth.token.permissions;
    }
    function isAdmin() {
      return role() == 'admin';
    }
    function isSupervisor() {
      return role() == 'supervisor';
    }
    function isDriver() {
      return role() == 'driver';
    }
    function isCustomer() {
      return role() == 'customer';
    }
    function inBranch(branchId) {
      return branchId in branchIds();
    }

    match /users/{userId} {
      allow read: if isAuthenticated() && (
        request.auth.uid == userId ||
        isAdmin() ||
        (isSupervisor() && inBranch(resource.data.primaryBranchId))
      );
      allow write: if isAdmin();
    }

    match /roles/{roleId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }

    match /permissions/{permId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }

    match /branches/{branchId} {
      allow read: if isAuthenticated() && (
        isAdmin() ||
        (isSupervisor() && inBranch(branchId)) ||
        (isDriver() && inBranch(branchId))
      );
      allow write: if isAdmin();
    }

    match /customers/{customerId} {
      allow read: if isAuthenticated() && (
        isAdmin() ||
        (isCustomer() && request.auth.uid == customerId) ||
        (isSupervisor() && inBranch(resource.data.branchId))
      );
      allow create: if isAdmin() || (isCustomer() && request.auth.uid == customerId);
      allow update: if isAdmin() || (isSupervisor() && inBranch(resource.data.branchId));
    }

    match /drivers/{driverId} {
      allow read: if isAuthenticated() && (
        isAdmin() ||
        (isDriver() && request.auth.uid == driverId) ||
        (isSupervisor() && inBranch(resource.data.branchIds[0]))
      );
      allow update: if isAdmin() ||
        (isDriver() && request.auth.uid == driverId &&
         !request.resource.data.diff(resource.data).affectedKeys()
           .hasAny(['status', 'branchIds', 'userId']));
      allow create: if isAdmin();
    }

    match /orders/{orderId} {
      allow read: if isAuthenticated() && (
        isAdmin() ||
        (isCustomer() && resource.data.customerId == request.auth.uid) ||
        (isDriver() && resource.data.driverId == request.auth.uid) ||
        (isSupervisor() && inBranch(resource.data.branchId))
      );
      // All writes go through Cloud Functions (no direct client writes)
      allow create, update, delete: if false;
    }

    match /order_events/{eventId} {
      allow read: if isAuthenticated() && (
        isAdmin() ||
        (isSupervisor() && inBranch(resource.data.branchId))
      );
      allow write: if false; // Functions only
    }

    match /products/{productId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin() || (isSupervisor() && hasPermission('products.update.branch'));
    }

    match /inventory/{inventoryId} {
      allow read: if isAuthenticated() && (
        isAdmin() ||
        (isSupervisor() && inBranch(resource.data.branchId)) ||
        (isDriver() && inBranch(resource.data.branchId))
      );
      allow write: if false; // Functions only
    }

    match /inventory_transactions/{txId} {
      allow read: if isAuthenticated() && (
        isAdmin() || (isSupervisor() && inBranch(resource.data.branchId))
      );
      allow write: if false;
    }

    match /payments/{paymentId} {
      allow read: if isAuthenticated() && (
        isAdmin() ||
        (isCustomer() && resource.data.customerId == request.auth.uid) ||
        (isSupervisor() && inBranch(resource.data.branchId))
      );
      allow write: if false;
    }

    match /notifications/{notificationId} {
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() &&
        resource.data.userId == request.auth.uid &&
        request.resource.data.diff(resource.data).affectedKeys().hasOnly(['read']);
      allow create, delete: if false;
    }

    match /settings/{settingId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }

    match /reports/{reportId} {
      allow read: if isAuthenticated() && (
        isAdmin() || (isSupervisor() && inBranch(resource.data.branchId))
      );
      allow write: if false;
    }

    match /archived_orders/{orderId} {
      allow read: if isAuthenticated() && (
        isAdmin() ||
        (isSupervisor() && inBranch(resource.data.branchId))
      );
      allow write: if false;
    }
  }
}
```

**Note:** Custom claims (`roleId`, `branchIds`, `permissions`) must be set by Cloud Functions on role assignment. Rules above assume claims are populated.
