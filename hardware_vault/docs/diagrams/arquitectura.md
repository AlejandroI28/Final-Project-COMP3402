# Diagrama de Arquitectura de Software — Hardware Vault

Aplicación Flutter monolítica con arquitectura por capas (presentation / state / data) y persistencia local en SQLite.

```mermaid
graph TB
    subgraph "Presentation Layer (Flutter Widgets)"
        Splash[SplashScreen]
        Shell[MainShell<br/>BottomNavigationBar]
        Catalog[CatalogScreen]
        News[NewsScreen]
        MyPC[MyEquipmentScreen]
        Detail[PartDetailScreen]
        Editor[_BuildEditor<br/>BottomSheet]
        Shared[shared_widgets.dart<br/>BrandBadge, ScoreBar,<br/>EmptyState, etc.]
    end

    subgraph "State Layer"
        Provider[ChangeNotifierProvider]
        State[AppState<br/>extends ChangeNotifier]
    end

    subgraph "Data Layer"
        Models[models.dart<br/>CPU, GPU,<br/>NewsArticle, PCBuild]
        Mock[mock_data.dart<br/>13 CPUs, 18 GPUs,<br/>8 News]
        DB[DatabaseHelper<br/>singleton]
    end

    subgraph "Persistence (Device)"
        SQLite[(SQLite<br/>hardware_vault.db<br/>tabla pc_builds)]
    end

    subgraph "Network (Image Assets)"
        Unsplash[Unsplash CDN<br/>News images]
        Local[assets/images/<br/>local product photos]
    end

    Splash --> Shell
    Shell --> Catalog
    Shell --> News
    Shell --> MyPC

    Catalog --> Detail
    MyPC --> Editor

    Catalog -. consume .-> State
    News -. consume .-> State
    MyPC -. consume .-> State
    Editor -. consume .-> State

    Catalog -. usa .-> Shared
    News -. usa .-> Shared
    MyPC -. usa .-> Shared
    Detail -. usa .-> Shared

    State -. notifyListeners .-> Provider
    Provider --> Shell

    State --> Models
    State --> Mock
    State --> DB

    DB --> SQLite

    News -. Image.network .-> Unsplash
    Catalog -. Image.asset .-> Local
    Detail -. Image.asset .-> Local
```

**Capas y responsabilidades:**

| Capa | Archivos | Responsabilidad |
|---|---|---|
| Presentation | `lib/screens/`, `lib/widgets/` | Pantallas Material y componentes reutilizables |
| State | `lib/providers/app_state.dart` | Estado global con Provider/ChangeNotifier (filtros catálogo, builds, etc.) |
| Data — Models | `lib/models/models.dart` | Modelos inmutables/mutables de dominio |
| Data — Mock | `lib/data/mock_data.dart` | Catálogo de hardware (datos de solo lectura) |
| Data — DB | `lib/data/database.dart` | Helper SQLite (singleton) para CRUD de PCBuilds |
| Theme | `lib/theme/app_theme.dart` | Paleta de colores y estilos globales |
| Bootstrap | `lib/main.dart` | Inicialización + navegación raíz |

**Patrones aplicados:**

- **Provider / ChangeNotifier** — gestión reactiva del estado.
- **Singleton** — `DatabaseHelper.instance` garantiza una sola conexión a la DB.
- **Repository (informal)** — `DatabaseHelper` aísla el SQL del resto del código; `AppState` expone una API limpia (`loadBuilds`, `saveBuild`, `deleteBuild`).
- **Composition over inheritance** — widgets pequeños y reutilizables (`BrandBadge`, `EmptyState`, `ScoreBar`).
