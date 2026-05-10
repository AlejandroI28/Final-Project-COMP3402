# 🖥️ Hardware Vault

> **Proyecto Capstone — COMP3402 Ingeniería de Software II**
> Profesor: Javier Dastas
> Estudiante: Alejandro Ruiz
> Repositorio: <https://github.com/AlejandroI28/Final-Project-COMP3402>

Aplicación móvil Flutter para explorar hardware de computadoras: catálogo navegable de CPUs y GPUs, feed de noticias del sector, y un gestor de builds de PC personales con persistencia local en SQLite.

---

## 📋 Tabla de contenido

1. [Descripción del problema](#-descripción-del-problema)
2. [Objetivo del sistema](#-objetivo-del-sistema)
3. [Usuarios / público objetivo](#-usuarios--público-objetivo)
4. [Tecnologías utilizadas](#-tecnologías-utilizadas)
5. [Arquitectura general](#-arquitectura-general)
6. [Módulos / componentes](#-módulos--componentes)
7. [Cómo ejecutar el proyecto](#-cómo-ejecutar-el-proyecto)
8. [Estructura del repositorio](#-estructura-del-repositorio)
9. [Descripción de la base de datos](#-descripción-de-la-base-de-datos)
10. [Evidencia del uso de SCRUM](#-evidencia-del-uso-de-scrum)
11. [Evidencia del uso de testing](#-evidencia-del-uso-de-testing)
12. [Estado actual del proyecto](#-estado-actual-del-proyecto)
13. [Mejoras futuras](#-mejoras-futuras)
14. [Enlaces a videos y presentaciones](#-enlaces-a-videos-y-presentaciones)
15. [Capturas clave](#-capturas-clave)
16. [Reflexión final](#-reflexión-final)

---

## 🎯 Descripción del problema

Quien arma una PC enfrenta un proceso disperso: las especificaciones de cada componente están repartidas entre páginas de fabricantes, las noticias técnicas en blogs especializados, y cualquier intento de documentar una build personal termina en notas sueltas o spreadsheets. No existe un único punto donde:

1. **Comparar** rápidamente CPUs y GPUs por marca, serie, precio y benchmark.
2. **Mantenerse al día** con noticias del sector (lanzamientos, eventos, reviews).
3. **Documentar y persistir** las builds armadas, con sus componentes, RAM, almacenamiento y notas.

Hardware Vault unifica esos tres flujos en una app móvil ligera, sin login ni dependencias en la nube.

## 🚀 Objetivo del sistema

Proveer una aplicación móvil **offline-first** que permita a entusiastas de PC:

- **Explorar** un catálogo curado de CPUs (Intel, AMD) y GPUs (Nvidia, AMD, Intel) con búsqueda y filtros encadenables.
- **Leer** un feed de noticias técnicas con imágenes y categorización (GPU / CPU / Memory / Event).
- **Crear, editar, persistir y eliminar** builds personales en una base de datos local SQLite.

## 👥 Usuarios / público objetivo

| Perfil | Descripción |
|---|---|
| **Entusiasta de PC** | Conoce hardware, sigue lanzamientos, planea upgrades y disfruta comparar specs. |
| **Builder novato** | Está armando su primera PC y necesita una vista clara de componentes y rangos de precio. |
| **Estudiante de ingeniería** | Usa la app como referencia rápida durante cursos de arquitectura de computadoras. |

La interfaz prioriza **lectura rápida** (cards densos, badges de marca, score bars) sobre transacciones — no hay carrito ni checkout.

## 🛠️ Tecnologías utilizadas

| Categoría | Tecnología | Versión / Notas |
|---|---|---|
| Lenguaje | Dart | 3.0+ |
| Framework | Flutter | 3.x — Material 3, dark mode |
| Estado | `provider` | ^6.1.1 — patrón ChangeNotifier |
| Persistencia | `sqflite` + `path` | ^2.3.0 — SQLite local |
| Tipografía | `google_fonts` | Space Grotesk |
| Fechas relativas | `timeago` | ^3.6.0 |
| UI auxiliar | `flutter_staggered_animations`, `cached_network_image`, `shimmer`, `flutter_svg` | — |
| Testing | `flutter_test` | Tests sobre `AppState` con `ChangeNotifier` |
| DevOps | GitHub | Repo + commits + ramas |

## 🏗️ Arquitectura general

Arquitectura por **capas** dentro de una sola app Flutter (no hay backend):

```
┌─────────────────────────────────────────────────────────┐
│  Presentation     screens/  +  widgets/                 │
│  (Material UI)    SplashScreen, MainShell, Catalog,     │
│                   News, MyEquipment, PartDetail, etc.   │
├─────────────────────────────────────────────────────────┤
│  State            providers/app_state.dart              │
│                   AppState (extends ChangeNotifier)     │
├─────────────────────────────────────────────────────────┤
│  Data             models/    + data/                    │
│                   CPU, GPU, NewsArticle, PCBuild        │
│                   mock_data.dart  (catálogo read-only)  │
│                   database.dart   (SQLite helper)       │
├─────────────────────────────────────────────────────────┤
│  Persistence      SQLite local — hardware_vault.db      │
└─────────────────────────────────────────────────────────┘
```

Diagramas detallados:
- [docs/diagrams/flujo_funcional.md](docs/diagrams/flujo_funcional.md)
- [docs/diagrams/arquitectura.md](docs/diagrams/arquitectura.md)
- [docs/diagrams/diagrama_er.md](docs/diagrams/diagrama_er.md)

## 🧩 Módulos / componentes

| Módulo | Archivo principal | Responsabilidad |
|---|---|---|
| **Bootstrap** | [lib/main.dart](lib/main.dart) | Inicialización de la app, `MaterialApp`, `MainShell` y bottom nav (Catalog / News / My PC). |
| **Splash** | [lib/screens/splash_screen.dart](lib/screens/splash_screen.dart) | Pantalla de inicio con fade-in simple, ~1.4s antes de navegar. |
| **Catalog** | [lib/screens/catalog_screen.dart](lib/screens/catalog_screen.dart) | Búsqueda, filtros (Type/Brand/Series), sort, botón Search/Clear, listas agrupadas. |
| **News** | [lib/screens/news_screen.dart](lib/screens/news_screen.dart) | Feed de noticias con search bar, card destacado y lista. |
| **My PC** | [lib/screens/my_equipment_screen.dart](lib/screens/my_equipment_screen.dart) | CRUD de builds en SQLite, BottomSheet editor, diálogo de confirmación. |
| **Detail** | [lib/screens/part_detail_screen.dart](lib/screens/part_detail_screen.dart) | Ficha técnica de CPU/GPU con specs, score bar y header con imagen. |
| **State** | [lib/providers/app_state.dart](lib/providers/app_state.dart) | Estado global: filtros de catálogo, lista de builds, navegación. |
| **DB** | [lib/data/database.dart](lib/data/database.dart) | Singleton `DatabaseHelper` para CRUD de `pc_builds` en SQLite. |
| **Models** | [lib/models/models.dart](lib/models/models.dart) | `CPU`, `GPU`, `NewsArticle`, `PCBuild`. |
| **Mock data** | [lib/data/mock_data.dart](lib/data/mock_data.dart) | 13 CPUs, 18 GPUs, 8 noticias. |
| **Theme** | [lib/theme/app_theme.dart](lib/theme/app_theme.dart) | Paleta dark verde + colores de marca. |
| **Widgets compartidos** | [lib/widgets/shared_widgets.dart](lib/widgets/shared_widgets.dart) | `BrandBadge`, `ScoreBar`, `EmptyState`, helpers de imágenes. |

## ▶️ Cómo ejecutar el proyecto

### Requisitos

- Flutter SDK 3.0+ y Dart 3.0+
- Android Studio o VS Code con plugin Flutter
- Un emulador Android (probado en Pixel 3a API 34) o un dispositivo físico

### Pasos

```bash
# 1) Clonar el repo
git clone https://github.com/AlejandroI28/Final-Project-COMP3402.git
cd Final-Project-COMP3402

# 2) Instalar dependencias
flutter pub get

# 3) Listar dispositivos disponibles
flutter devices

# 4) Ejecutar en el emulador / dispositivo
flutter run -d emulator-5554

# (Opcional) Build APK release
flutter build apk --release

# Correr tests
flutter test
```

> **Nota Windows desktop:** la app no construye en Windows desktop sin Visual Studio con C++ workload. Para evaluación, usar el emulador Android.

## 📁 Estructura del repositorio

```
hardware_vault/
├── android/                    # Configuración Android (manifest con INTERNET permission)
├── ios/                        # Stub iOS
├── lib/
│   ├── main.dart              # Bootstrap + MainShell + bottom nav
│   ├── theme/
│   │   └── app_theme.dart
│   ├── models/
│   │   └── models.dart        # CPU, GPU, NewsArticle, PCBuild
│   ├── data/
│   │   ├── mock_data.dart     # Catálogo read-only
│   │   └── database.dart      # Helper SQLite (sqflite)
│   ├── providers/
│   │   └── app_state.dart     # Estado global con ChangeNotifier
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── catalog_screen.dart
│   │   ├── news_screen.dart
│   │   ├── my_equipment_screen.dart
│   │   └── part_detail_screen.dart
│   └── widgets/
│       └── shared_widgets.dart
├── test/
│   ├── app_state_test.dart    # 12 tests sobre filtrado, sort, search state
│   └── widget_test.dart       # 2 tests sobre ChangeNotifier
├── assets/
│   └── images/                # Logos, RTX 3000/4000/5000, ryzen, intel, radeon, arc
├── docs/
│   ├── diagrams/
│   │   ├── flujo_funcional.md
│   │   ├── arquitectura.md
│   │   └── diagrama_er.md
│   ├── uat_tests.md           # 3 UAT funcionales + 3 UAT UI
│   └── scrum_evidence.md      # Backlog + sprints
├── pubspec.yaml
└── README.md                  # Este archivo
```

## 🗄️ Descripción de la base de datos

La app usa **SQLite local** (paquete `sqflite`) para persistir los builds del usuario. El archivo `hardware_vault.db` se crea automáticamente en el directorio de bases de datos del dispositivo en el primer arranque.

### Tabla `pc_builds`

```sql
CREATE TABLE pc_builds (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  cpu_id        TEXT,
  gpu_id        TEXT,
  ram_gb        INTEGER NOT NULL DEFAULT 16,
  ram_type      TEXT NOT NULL DEFAULT 'DDR5',
  storage_gb    INTEGER NOT NULL DEFAULT 1000,
  storage_type  TEXT NOT NULL DEFAULT 'NVMe SSD',
  psu_watts     TEXT,
  case_model    TEXT,
  notes         TEXT NOT NULL DEFAULT '',
  created_at    TEXT NOT NULL,
  updated_at    TEXT NOT NULL
);
```

`cpu_id` y `gpu_id` son referencias lógicas a los IDs del catálogo en código (`mock_data.dart`). El catálogo no se replica en la DB — solo los builds del usuario.

Diccionario completo en [docs/diagrams/diagrama_er.md](docs/diagrams/diagrama_er.md).

### Operaciones expuestas por `DatabaseHelper`

| Método | SQL ejecutado |
|---|---|
| `getAllBuilds()` | `SELECT * FROM pc_builds ORDER BY updated_at DESC` |
| `upsertBuild(b)` | `INSERT OR REPLACE INTO pc_builds VALUES(...)` |
| `deleteBuild(id)` | `DELETE FROM pc_builds WHERE id = ?` |
| `clearAll()` | `DELETE FROM pc_builds` |

## 📊 Evidencia del uso de SCRUM

El proyecto se ejecutó como sprint solo (1 estudiante) con backlog organizado por iteraciones temáticas. Detalle en [docs/scrum_evidence.md](docs/scrum_evidence.md).

| Sprint | Foco | Entregables clave |
|---|---|---|
| **Sprint 1** | Scaffolding | Bootstrap Flutter, theme, modelos, mock data, navegación |
| **Sprint 2** | Catálogo + News base | CatalogScreen con filtros, NewsScreen con feed |
| **Sprint 3** | My PC + persistencia inicial | CRUD de builds, BottomSheet editor |
| **Sprint 4** | i18n + UX polish | Traducción al inglés, splash simplificado, imágenes de productos, search bar en News |
| **Sprint 5** | UX catálogo avanzado | Search button, Clear button condicional, filtro "All", imágenes locales por brand |
| **Sprint 6** | Hardening + entregables | Migración a SQLite, unit tests, diagramas, documentación |

**Evidencia en GitHub:** historial de commits con mensajes descriptivos, organización en carpetas (`lib/`, `test/`, `docs/`, `assets/`).

## 🧪 Evidencia del uso de testing

### Pruebas unitarias — `flutter test` (14 tests pasando)

Archivo: [test/app_state_test.dart](test/app_state_test.dart) + [test/widget_test.dart](test/widget_test.dart)

Cubren:

- **Catalog filtering — CPUs (3 tests):** retorno completo sin filtros, filtrado por marca, búsqueda case-insensitive.
- **Catalog filtering — GPUs (2 tests):** filtro por marca Nvidia, sort ascendente por precio.
- **Catalog search state machine (5 tests):** `hasSearched` inicial, `runCatalogSearch`, `clearCatalogFilters`, `hasActiveCatalogFilters`, reset al cambiar tab.
- **Catalog "All" tab (2 tests):** `availableBrands` combinado, `setBrandFilter` sincroniza CPU+GPU.
- **AppState notifications (2 tests):** `notifyListeners` se dispara en `setSearch` y `setSortBy`.

Salida:
```
00:00 +14: All tests passed!
```

### Pruebas UAT — funcionales y UI

Documentadas en [docs/uat_tests.md](docs/uat_tests.md) con la estructura exigida (ID, tipo, título, objetivo, precondiciones, pasos, resultado esperado, resultado obtenido, estado, evidencia):

| ID | Tipo | Caso |
|---|---|---|
| UAT-F-01 | Funcional | Crear y persistir un nuevo build |
| UAT-F-02 | Funcional | Búsqueda en catálogo respeta el botón Search |
| UAT-F-03 | Funcional | Eliminar un build con confirmación |
| UAT-UI-01 | UI | Empty state del catálogo y aparición condicional del botón Clear |
| UAT-UI-02 | UI | Renderizado de imágenes en News con loader y fallback |
| UAT-UI-03 | UI | Splash termina y aterriza en News sin glitch |

## 🔵 Estado actual del proyecto

**Estable.** Todas las pantallas funcionan, SQLite persiste correctamente entre sesiones, los 14 unit tests pasan y los flujos UAT han sido ejecutados manualmente con éxito en emulador Pixel 3a API 34.

## 🔮 Mejoras futuras

- **Real-time news:** reemplazar mock por un feed real (RSS o API tipo NewsAPI).
- **Cloud sync opcional** de builds (Firebase Auth + Firestore) preservando modo offline.
- **Compatibilidad de componentes:** validar socket/PSU/slot al armar un build (advertencias en el editor).
- **Comparador lado a lado** de dos componentes (CPU vs CPU, GPU vs GPU).
- **Gráficas de benchmark** con `fl_chart` en la pantalla de detalle.
- **Localización i18n** real con `flutter_localizations` (hoy todo está hardcoded en inglés).
- **CI con GitHub Actions:** correr `flutter test` y `flutter analyze` en cada push.

## 🎬 Enlaces a videos y presentaciones

| Recurso | Enlace / ubicación |
|---|---|
| Video 1 — Flujo / uso de la app | _(pendiente de grabación)_ |
| Video 2 — Aspectos técnicos | _(pendiente de grabación)_ |
| Documento formal del proyecto (PDF) | Entregado por separado — generado con `python docs/generate_pdf.py` |
| Presentación 1 (PPTX) | Entregada por separado — generada con `python docs/generate_presentations.py` |
| Presentación 2 (PPTX) | Entregada por separado — generada con `python docs/generate_presentations.py` |

> Los scripts `docs/generate_pdf.py` y `docs/generate_presentations.py` escriben los entregables en `~/Downloads/Capstone_Entregables/` para mantener el repositorio limpio de archivos binarios pesados.

## 📸 Capturas clave

| Pantalla | Archivo | Captura |
|---|---|---|
| Splash | [splash_screen.dart](lib/screens/splash_screen.dart) | `docs/evidence/splash.png` |
| News | [news_screen.dart](lib/screens/news_screen.dart) | `docs/evidence/news.png` |
| Catalog (empty) | [catalog_screen.dart](lib/screens/catalog_screen.dart) | `docs/evidence/catalog_empty.png` |
| Catalog (results) | [catalog_screen.dart](lib/screens/catalog_screen.dart) | `docs/evidence/catalog_results.png` |
| Part Detail | [part_detail_screen.dart](lib/screens/part_detail_screen.dart) | `docs/evidence/part_detail.png` |
| My PC (build editor) | [my_equipment_screen.dart](lib/screens/my_equipment_screen.dart) | `docs/evidence/build_editor.png` |

## 💭 Reflexión final

### Reflexión individual — Alejandro Ruiz

Llevar Hardware Vault de scaffolding a entrega Capstone reforzó dos cosas que el curso enfatizó: **la separación de responsabilidades paga dividendos** y **el testing es más fácil cuanto antes se planifique**. Tener un `AppState` puro como `ChangeNotifier` permitió escribir 14 unit tests sin tocar la UI ni la base de datos, porque los filtros del catálogo y la máquina de estados de búsqueda son lógica determinista.

La migración de SharedPreferences a SQLite fue el cambio más educativo: parecía una decisión de "infraestructura" pero terminó habilitando un diagrama ER real, una tabla con tipos validados y un diccionario de datos defendible frente a la rúbrica. La conclusión personal — el rubric no penaliza por elegir la herramienta más simple, pero sí premia que la elección sea justificable.

Lo más difícil fue la disciplina de **no hacer scope creep**: cada vez que agregué una feature (búsqueda en News, "All" en el filtro Type, botón Clear condicional), tuve que resistir la tentación de añadir cinco más alrededor. Mantener cada cambio pequeño, ejecutarlo en el emulador, y verificar antes de pasar al siguiente, fue la única forma de no romper el sistema.

### Reflexión grupal

Aunque el equipo es individual (1 integrante), la dinámica de proyecto Capstone obligó a operar como si hubiese múltiples roles: planner que define backlog, dev que implementa, tester que valida, y documenter que mantiene README + diagramas. Forzar esa rotación mental por sprint dejó claro que **la metodología SCRUM no es solo ceremonia** — incluso en solo, separar la planificación de la ejecución reduce errores y permite cumplir entregables a tiempo.

El proyecto demuestra que se puede entregar una aplicación móvil funcional, con persistencia real, pruebas automáticas, y documentación rigurosa, dentro del alcance de un curso, siempre que las decisiones técnicas se tomen pensando en lo que la rúbrica está midiendo.
