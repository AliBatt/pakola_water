# Architecture Diagrams

Visual reference for authentication, data flow, notifications, and dependency graphs.

---

## 1. Authentication Flow

```mermaid
flowchart TD
    A[App Launch] --> B{Firebase Auth State?}
    B -->|No user| C[Login Screen]
    B -->|Has user| D[Fetch users/uid profile]
    
    C --> E[signInWithEmailAndPassword]
    E -->|Success| D
    E -->|Failure| F[Map Auth Error → UI]
    F --> C
    
    D --> G{Profile status?}
    G -->|suspended| H[Suspended Screen]
    G -->|pending| I[Pending Approval Screen]
    G -->|active| J[Load roles/roleId permissions]
    
    J --> K[Build PermissionSet]
    K --> L{Match role to app?}
    L -->|Yes| M[Navigate to Dashboard]
    L -->|No| N[Unauthorized / Wrong App]
    
    M --> O[Register FCM Token via CF]
    O --> P[App Ready]
```

---

## 2. Role-Based App Routing

```mermaid
flowchart LR
    subgraph Auth
        Login[Login]
    end
    
    subgraph RoleCheck
        RC{roleId}
    end
    
    subgraph Apps
        CA[Customer App<br/>Dashboard]
        DA[Driver App<br/>Deliveries]
        SA[Supervisor App<br/>Branch Ops]
        AW[Admin Web<br/>Global Admin]
    end
    
    Login --> RC
    RC -->|customer| CA
    RC -->|driver| DA
    RC -->|supervisor| SA
    RC -->|admin| AW
```

---

## 3. Firestore Data Flow

```mermaid
flowchart TB
    subgraph Write Path - Complex
        C1[Client] -->|httpsCallable| CF[Cloud Function]
        CF -->|transaction| FS[(Firestore)]
        CF -->|trigger| CF2[Side Effect Functions]
        CF2 --> FS
    end
    
    subgraph Write Path - Simple
        C2[Client] -->|direct write| FS2[(Firestore)]
        FS2 -->|security rules| SR{Allowed?}
    end
    
    subgraph Read Path
        C3[Client] -->|query/stream| FS3[(Firestore)]
        FS3 -->|security rules| SR2{Allowed?}
        SR2 -->|yes| C3
    end
```

---

## 4. Order Lifecycle

```mermaid
stateDiagram-v2
    [*] --> pending: Customer creates order (CF)
    pending --> confirmed: Supervisor confirms
    confirmed --> assigned: Supervisor assigns driver (CF)
    assigned --> out_for_delivery: Driver starts delivery
    out_for_delivery --> delivered: Driver completes (CF)
    
    pending --> cancelled: Cancel
    confirmed --> cancelled: Cancel
    assigned --> cancelled: Cancel
    out_for_delivery --> failed: Delivery failed
    
    delivered --> [*]
    cancelled --> [*]
    failed --> [*]
```

---

## 5. Notification Flow

```mermaid
sequenceDiagram
    autonumber
    participant C as Customer App
    participant CF as Cloud Functions
    participant FS as Firestore
    participant FCM as FCM
    participant S as Supervisor App
    participant D as Driver App

  Note over C,D: Order Created
    C->>CF: createOrder()
    CF->>FS: Write order + inventory tx
    CF->>CF: sendPushNotification()
    CF->>FS: Write notifications doc
    CF->>FCM: Multicast to branch supervisors
    FCM->>S: Push: New order

  Note over C,D: Driver Assigned
    S->>CF: assignDriver()
    CF->>FS: Update order.driverId
    CF->>FCM: Push to driver
    FCM->>D: Push: New assignment

  Note over C,D: Delivery Complete
    D->>CF: updateOrderStatus(delivered)
    CF->>FS: Update order.status
    CF->>FCM: Push to customer
    FCM->>C: Push: Order delivered
```

---

## 6. Dependency Graph

```mermaid
flowchart BT
    subgraph Apps Layer
        customer[customer_app]
        driver[driver_app]
        supervisor[supervisor_app]
        admin[admin_web]
    end
    
    subgraph Presentation Packages
        auth_pkg[auth]
        routing[routing]
        ui[ui_kit]
        notif[notifications]
        feat[feature_*]
    end
    
    subgraph Data Layer
        data[data]
    end
    
    subgraph Domain Layer
        domain[domain]
    end
    
    subgraph Infrastructure
        firebase[firebase]
        core[core]
    end
    
    customer --> auth_pkg
    customer --> routing
    customer --> ui
    customer --> feat
    
    driver --> auth_pkg
    driver --> routing
    driver --> ui
    driver --> feat
    
    supervisor --> auth_pkg
    supervisor --> routing
    supervisor --> ui
    supervisor --> feat
    
    admin --> auth_pkg
    admin --> routing
    admin --> ui
    admin --> feat
    
    auth_pkg --> data
    auth_pkg --> domain
    routing --> auth_pkg
    feat --> data
    feat --> domain
    feat --> ui
    notif --> data
    notif --> ui
    
    data --> domain
    data --> firebase
    data --> core
    
    firebase --> core
    auth_pkg --> core
    domain --> core
```

---

## 7. Repository Pattern

```mermaid
classDiagram
    class OrderRepository {
        <<interface>>
        +getOrdersByBranch(query) Result~List~Order~~
        +getOrderById(id) Result~Order~
        +watchAssignedOrders(driverId) Stream~Result~
        +createOrder(params) Result~Order~
        +updateOrderStatus(params) Result~void~
    }
    
    class OrderRepositoryImpl {
        -OrderRemoteDataSource _remote
        +getOrdersByBranch(query)
        +createOrder(params)
    }
    
    class OrderRemoteDataSource {
        -FirestoreService _firestore
        -CloudFunctionsService _functions
        +fetchOrders(query)
        +callCreateOrder(params)
    }
    
    class CreateOrder {
        -OrderRepository _repo
        +call(params) Result~Order~
    }
    
    class OrderListController {
        +build() AsyncValue~List~Order~~
    }
    
    OrderRepositoryImpl ..|> OrderRepository
    OrderRepositoryImpl --> OrderRemoteDataSource
    CreateOrder --> OrderRepository
    OrderListController --> CreateOrder
```

---

## 8. Clean Architecture Layers

```mermaid
flowchart TB
    subgraph Presentation
        W[Widgets / Screens]
        P[Riverpod Providers / Controllers]
    end
    
    subgraph Domain
        E[Entities]
        UC[Use Cases]
        RI[Repository Interfaces]
    end
    
    subgraph Data
        RE[Repository Implementations]
        DTO[DTOs + Mappers]
        DS[Data Sources]
    end
    
    subgraph Firebase
        SVC[Services]
    end
    
    W --> P
    P --> UC
    UC --> RI
    UC --> E
    RE -.-> RI
    RE --> DS
    DS --> SVC
    
    style Domain fill:#e8f5e9
    style Firebase fill:#fff3e0
    style Presentation fill:#e3f2fd
    style Data fill:#fce4ec
```

---

## 9. Environment Deployment

```mermaid
flowchart LR
    subgraph Dev
        D1[water-delivery-dev]
        D2[Emulators]
    end
    
    subgraph Staging
        S1[water-delivery-staging]
    end
    
    subgraph Production
        P1[water-delivery-prod]
    end
    
    Dev -->|QA pass| Staging
    Staging -->|Approval| Production
    
    D1 --- D2
```

---

## 10. Scalability — Branch Partitioning

```mermaid
flowchart TB
    subgraph Branch A
        OA[orders<br/>branchId=A]
        IA[inventory<br/>branchId=A]
    end
    
    subgraph Branch B
        OB[orders<br/>branchId=B]
        IB[inventory<br/>branchId=B]
    end
    
    subgraph Global
        PR[products]
        RO[roles]
        SE[settings/global]
    end
    
    Q1[Supervisor Query] -->|where branchId=A| OA
    Q2[Driver Query] -->|where driverId + status| OA
    Q3[Admin Query] -->|paginated all branches| OA
    Q3 --> OB
```
