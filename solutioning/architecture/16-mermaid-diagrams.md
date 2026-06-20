# Mermaid Architecture Diagrams

## 1. Dependency Graph

```mermaid
graph TD
    subgraph "Shell Layer"
        SHELL[rt-rw-digital]
        REG[ModuleRegistry]
        FF[FeatureFlagService]
        VER[VersionCompatibility]
    end

    subgraph "Feature Modules"
        RES[resident_module]
        FIN[finance_module]
        COM[complaint_module]
        MEE[meeting_module]
        SEC[security_module]
    end

    subgraph "Shared Kernel"
        CORE[core_module]
        CONTRACTS[module_contracts]
        EVT[ModuleEventBus]
    end

    subgraph "External"
        API[Backend API]
        FF_API[Feature Flag API]
    end

    %% Shell dependencies
    SHELL --> REG
    SHELL --> FF
    SHELL --> VER
    SHELL --> CORE
    SHELL --> CONTRACTS

    %% Registry manages modules
    REG --> RES
    REG --> FIN
    REG --> COM
    REG --> MEE
    REG --> SEC

    %% Feature flags
    FF --> FF_API
    FF --> REG

    %% Version checks
    VER --> REG

    %% Module dependencies
    RES --> CORE
    RES --> CONTRACTS
    FIN --> CORE
    FIN --> CONTRACTS
    COM --> CORE
    COM --> CONTRACTS
    MEE --> CORE
    MEE --> CONTRACTS
    SEC --> CORE
    SEC --> CONTRACTS

    %% Event bus (cross-module communication)
    RES -.->|publish| EVT
    FIN -.->|listen| EVT

    %% Backend
    SHELL --> API
    RES --> API
    FIN --> API

    %% Style
    classDef shell fill:#e1f5fe,stroke:#01579b
    classDef module fill:#fff3e0,stroke:#e65100
    classDef kernel fill:#e8f5e9,stroke:#1b5e20
    classDef external fill:#f3e5f5,stroke:#4a148c

    class SHELL,REG,FF,VER shell
    class RES,FIN,COM,MEE,SEC module
    class CORE,CONTRACTS,EVT kernel
    class API,FF_API external
```

## 2. Bootstrap Flow

```mermaid
sequenceDiagram
    participant App as main()
    participant Reg as ModuleRegistry
    participant ResMod as ResidentModule
    participant FinMod as FinanceModule
    participant FF as FeatureFlagService
    participant Comp as VersionCompatibility
    participant Router as GoRouter
    participant API as Backend API

    App->>Reg: create ModuleRegistry()
    App->>Reg: registerAll([ResidentModule, FinanceModule, ...])
    
    par Module Registration
        Reg->>ResMod: get manifest
        ResMod-->>Reg: manifest
        Reg->>FinMod: get manifest
        FinMod-->>Reg: manifest
    end

    App->>FF: setFeatureFlagService()
    App->>FF: load()
    FF->>API: GET /api/v1/feature-flags
    API-->>FF: { resident.enabled: true, finance.enabled: false }
    FF-->>App: loaded

    App->>Comp: checkAll(manifests)
    Comp->>ResMod: checkModuleCompatibility()
    ResMod-->>Comp: compatible: true
    Comp->>FinMod: checkModuleCompatibility()
    FinMod-->>Comp: compatible: true
    Comp-->>App: results (no blocking)

    App->>Reg: get enabledModules
    Reg->>FF: isEnabled('resident')
    FF-->>Reg: true
    Reg->>FF: isEnabled('finance')
    FF-->>Reg: false
    Reg-->>App: [ResidentModule]

    loop each enabled module
        App->>ResMod: setupDependencies()
        ResMod-->>App: DI initialized
        App->>ResMod: initialize()
        ResMod-->>App: ready
    end

    App->>Reg: allRoutes
    Reg->>ResMod: get routes
    ResMod-->>Reg: [GoRoute('/resident', ...)]
    Reg-->>App: combined routes

    App->>Router: GoRouter(routes: combined)
    Router-->>App: configured

    App->>App: runApp(MyApp(registry: registry))
```

## 3. Module Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Registered : ModuleRegistry.register()
    
    Registered --> DependenciesSetup : FeatureModule.setupDependencies()
    
    DependenciesSetup --> Initialized : FeatureModule.initialize()
    
    Initialized --> Active : FeatureFlags enabled
    Initialized --> Inactive : FeatureFlags disabled
    
    Active --> Inactive : Flag changed to disabled
    Inactive --> Active : Flag changed to enabled
    
    Active --> Error : initialize() throws
    Error --> [*] : Module removed from registry
    
    Inactive --> [*] : Module unregistered
    
    state Active {
        [*] --> RoutesExposed
        RoutesExposed --> HandlingNavigation
        HandlingNavigation --> RoutesExposed
    end
```

## 4. Route Registration Flow

```mermaid
sequenceDiagram
    participant Shell as Shell App
    participant Registry as ModuleRegistry
    participant ResMod as ResidentModule
    participant FinMod as FinanceModule
    participant Router as GoRouter

    Shell->>Registry: getAllRoutes()

    Registry->>ResMod: get routes
    ResMod-->>Registry: [GoRoute('/resident/*')]

    Registry->>FinMod: get routes
    FinMod-->>Registry: [GoRoute('/finance/*')]

    Registry->>Registry: check for conflicts
    Note over Registry: /resident/ != /finance/ → no conflict
    Note over Registry: First module with same path wins

    Registry-->>Shell: [GoRoute('/resident/*'), GoRoute('/finance/*')]

    Shell->>Router: GoRouter(routes: combined + shell routes)
    Router-->>Shell: ready

    Note over Shell,Router: Deep link received: rt-rw://resident/123

    Router->>Router: match path '/resident/123'
    Router->>ResMod: ResidentDetailPage(id: '123')
```

## 5. Feature Flag Flow

```mermaid
sequenceDiagram
    participant App as App
    participant Cache as Local Cache
    participant API as Backend API
    participant Reg as ModuleRegistry
    participant UI as User Interface

    App->>Cache: load cached flags
    Cache-->>App: {resident: true, finance: false}

    par Load fresh flags
        App->>API: GET /api/v1/feature-flags
        API-->>App: {resident: true, finance: true, export: false}
        App->>Cache: update cache
    end

    App->>Reg: refreshFromFeatureFlags()

    Reg->>Reg: resident.enabled = true → keep enabled
    Reg->>Reg: finance.enabled = true → enable finance

    Note over Reg: Finance module was disabled, now enabled

    Reg->>UI: rebuild navigation
    UI->>Reg: get enabledModules
    Reg-->>UI: [ResidentModule, FinanceModule]
    UI->>UI: show finance menu item

    Note over App,UI: Later...

    API->>App: WebSocket: flag change event
    App->>Reg: refreshFromFeatureFlags()
    Reg->>Reg: finance.enabled = false → disable finance
    Reg->>UI: rebuild navigation
    UI->>Reg: get enabledModules
    Reg-->>UI: [ResidentModule]
    UI->>UI: hide finance menu item
```

## 6. Version Compatibility Flow

```mermaid
flowchart TD
    START([Bootstrap Start]) --> CHECK[Read shell version\nfrom pubspec.yaml]
    CHECK --> LOAD[Load module manifests]
    LOAD --> COMPARE{For each module:\nshell >= minShellVersion?}
    
    COMPARE -->|Yes| WARN{recommendedShellVersion\n!= null &&\nshell < recommended?}
    COMPARE -->|No| BLOCK[Mark module as incompatible]
    BLOCK --> LOG_BLOCK[Log blocking error]
    LOG_BLOCK --> CONTINUE{Any blocking\nresults?}
    
    WARN -->|Yes| LOG_WARN[Log warning]
    WARN -->|No| OK[Module compatible]
    
    LOG_WARN --> OK
    OK --> CONTINUE
    
    CONTINUE -->|Yes| SHOW_UPDATE[Show forced update screen]
    CONTINUE -->|No| SHOW_WARN{Have warnings?}
    
    SHOW_UPDATE --> EXIT([Exit - user must update])
    
    SHOW_WARN -->|Yes| NOTIFY[Show non-blocking notification]
    SHOW_WARN -->|No| PROCEED([Continue bootstrap])
    NOTIFY --> PROCEED
```

## 7. Module Communication Flow (Event Bus)

```mermaid
sequenceDiagram
    participant ResMod as ResidentModule
    participant Bus as ModuleEventBus
    participant FinMod as FinanceModule
    participant Notif as NotificationService

    ResMod->>Bus: publish(ResidentCreated{id: '123', name: 'John'})
    
    par Listeners
        FinMod->>Bus: on<ResidentCreated>()
        Bus-->>FinMod: ResidentCreated event
        FinMod->>FinMod: auto-create iuran for new resident
        
        Notif->>Bus: on<ResidentCreated>()
        Bus-->>Notif: ResidentCreated event
        Notif->>Notif: send welcome notification
    end
```

## 8. AI-Agent Module Generation Flow

```mermaid
flowchart LR
    PROMPT[AI Agent Prompt] --> TEMPLATE[Module Template]
    TEMPLATE --> GENERATE{AI Agent\ngenerates}
    
    GENERATE --> MODULE[FeatureModule impl]
    GENERATE --> MANIFEST[ModuleManifest]
    GENERATE --> ROUTES[Route defs]
    GENERATE --> DOMAIN[Domain entities]
    GENERATE --> REPO[Repository interface]
    GENERATE --> IMPL[Repository impl]
    GENERATE --> UI[UI Pages]
    GENERATE --> TESTS[Test files]
    GENERATE --> YAML[module_manifest.yaml]
    
    MODULE --> REGISTER[Register in shell]
    MANIFEST --> REGISTER
    ROUTES --> REGISTER
    
    REGISTER --> VERIFY{Verify:}
    VERIFY --> V1[Routes work?]
    VERIFY --> V2[Flags respected?]
    VERIFY --> V3[Tests pass?]
    VERIFY --> V4[Boundaries clean?]
    
    V1 -->|Yes| DONE([Module ready])
    V2 -->|Yes| DONE
    V3 -->|Yes| DONE
    V4 -->|Yes| DONE
