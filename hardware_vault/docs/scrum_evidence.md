# Evidencia de SCRUM — Hardware Vault

Proyecto Capstone ejecutado por **1 integrante** (Alejandro Ruiz) bajo metodología SCRUM adaptada a equipo individual: cada sprint tiene un backlog explícito, un foco temático y entregables verificables.

## Product Backlog

| ID | Historia de usuario | Prioridad | Sprint |
|---|---|---|---|
| HU-01 | Como entusiasta, quiero ver un catálogo de CPUs y GPUs con sus specs. | Alta | 1, 2 |
| HU-02 | Como usuario, quiero filtrar el catálogo por marca y serie. | Alta | 2, 5 |
| HU-03 | Como usuario, quiero buscar componentes por nombre. | Alta | 2, 5 |
| HU-04 | Como usuario, quiero leer noticias del sector hardware. | Media | 2, 4 |
| HU-05 | Como usuario, quiero crear y guardar mis builds de PC. | Alta | 3 |
| HU-06 | Como usuario, quiero que mis builds persistan entre sesiones. | Alta | 3, 6 |
| HU-07 | Como usuario, quiero ver imágenes reales de los productos. | Media | 4, 5 |
| HU-08 | Como usuario, quiero la app en inglés. | Media | 4 |
| HU-09 | Como usuario, quiero un splash screen rápido y ligero. | Baja | 4 |
| HU-10 | Como usuario, quiero buscar dentro de las noticias. | Media | 4 |
| HU-11 | Como usuario, quiero que el catálogo no muestre nada hasta presionar Search. | Media | 5 |
| HU-12 | Como usuario, quiero un botón Clear para resetear filtros. | Media | 5 |
| HU-13 | Como usuario, quiero ver CPUs y GPUs juntos en un modo "All". | Baja | 5 |
| HU-14 | Como evaluador, quiero ver pruebas unitarias y UAT documentadas. | Alta | 6 |
| HU-15 | Como evaluador, quiero un diagrama ER real basado en una DB real. | Alta | 6 |

## Sprints

### Sprint 1 — Scaffolding (foundation)

**Objetivo:** levantar la app Flutter con navegación, theme y modelos.

| Tarea | Estado |
|---|---|
| Crear proyecto Flutter | ✅ |
| Definir paleta dark verde (`AppTheme`) | ✅ |
| Modelar `CPU`, `GPU`, `NewsArticle`, `PCBuild` | ✅ |
| Generar `mock_data.dart` (13 CPUs, 18 GPUs, 8 noticias) | ✅ |
| Implementar `MainShell` + `BottomNavigationBar` | ✅ |
| Splash screen inicial (versión animada) | ✅ |

### Sprint 2 — Catálogo + News base

**Objetivo:** primeras pantallas funcionales.

| Tarea | Estado |
|---|---|
| `CatalogScreen` con tabs CPU/GPU | ✅ |
| Búsqueda live + filtros Brand/Series | ✅ |
| `NewsScreen` con feed (featured + lista) | ✅ |
| `PartDetailScreen` con specs y score bar | ✅ |
| Widgets compartidos: `BrandBadge`, `EmptyState`, `ScoreBar` | ✅ |

### Sprint 3 — My PC + persistencia inicial

**Objetivo:** CRUD de builds del usuario.

| Tarea | Estado |
|---|---|
| `MyEquipmentScreen` con lista + empty state | ✅ |
| `_BuildEditor` BottomSheet (CPU, GPU, RAM, Storage, notas) | ✅ |
| Persistencia con `SharedPreferences` (JSON) | ✅ |
| Diálogo de confirmación al eliminar | ✅ |

### Sprint 4 — i18n + UX polish

**Objetivo:** internacionalización y mejoras visuales.

| Tarea | Estado |
|---|---|
| Traducir toda la app de español a inglés | ✅ |
| Simplificar splash (eliminar pinturas custom y glow) | ✅ |
| Asignar imágenes Unsplash a las 8 noticias | ✅ |
| Agregar permiso INTERNET a AndroidManifest | ✅ |
| Agregar search bar a la pantalla News | ✅ |

### Sprint 5 — UX catálogo avanzado

**Objetivo:** búsqueda intencional y mejoras visuales del catálogo.

| Tarea | Estado |
|---|---|
| Botón Search verde + estado `hasSearched` | ✅ |
| Empty state "Press search to begin" | ✅ |
| Botón Clear condicional (X aparece solo si hay filtros activos) | ✅ |
| Modo Type "All" combinando CPUs + GPUs | ✅ |
| Conectar imágenes locales por marca: `intel ultra`, `intel core`, `ryzen`, `radeonrx`, `intel arc` | ✅ |

### Sprint 6 — Hardening + entregables Capstone

**Objetivo:** alinear con la rúbrica del proyecto.

| Tarea | Estado |
|---|---|
| Migrar persistencia de SharedPreferences a SQLite (`sqflite`) | ✅ |
| Crear `DatabaseHelper` singleton con CRUD | ✅ |
| Refactorizar `AppState.loadBuilds/saveBuild/deleteBuild` | ✅ |
| Escribir 14 unit tests sobre `AppState` (`flutter test`) | ✅ |
| Generar 3 diagramas: flujo, arquitectura, ER | ✅ |
| Documentar 3 UAT funcionales + 3 UAT UI | ✅ |
| Actualizar README con todas las secciones requeridas | ✅ |
| Producir documento PDF + 2 presentaciones PPTX | ✅ |

## Evidencia de seguimiento

- **Repositorio GitHub:** <https://github.com/AlejandroI28/Final-Project-COMP3402> — commits frecuentes con mensajes descriptivos (un commit por feature/fix).
- **Carpetas organizadas:** `lib/` por capa (screens / providers / data / models / widgets / theme), `test/`, `docs/`, `assets/`.
- **Tracking de tareas:** este documento + el TodoWrite usado durante la sesión final.

## Definición de "Done"

Para cada historia de usuario:

1. Compila sin warnings (`flutter analyze`).
2. Corre en el emulador Android sin errores.
3. Si toca lógica de `AppState`: tiene al menos un unit test asociado.
4. Si toca UI: tiene un caso UAT que la cubre (funcional o de UI).
5. Documentada en este archivo o en el README.
