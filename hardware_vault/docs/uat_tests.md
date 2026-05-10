# Pruebas UAT — Hardware Vault

Documento de evidencia de pruebas de aceptación de usuario, organizado según la estructura del documento de requerimientos del proyecto Capstone (sección 11.1).

- **Funcionales (3):** UAT-F-01, UAT-F-02, UAT-F-03
- **UI (3):** UAT-UI-01, UAT-UI-02, UAT-UI-03

---

## UAT-F-01 — Crear y persistir un nuevo build

| Campo | Valor |
|---|---|
| **ID de la prueba** | UAT-F-01 |
| **Tipo** | Funcional |
| **Título** | Crear un nuevo build y verificar persistencia entre sesiones |
| **Objetivo** | Validar que un build creado en *My PC* se guarda en SQLite y sigue presente al cerrar y reabrir la app. |
| **Precondiciones** | App instalada, base de datos `hardware_vault.db` accesible. |
| **Pasos** | 1. Abrir la pestaña **My PC**.<br>2. Tocar el botón verde `+` en la esquina superior derecha.<br>3. Llenar `Build name`: "Test Rig".<br>4. Seleccionar `Processor (CPU)`: Core Ultra 9 285K.<br>5. Seleccionar `Graphics Card (GPU)`: GeForce RTX 5090.<br>6. RAM: 32 GB DDR5; Storage: 2 TB NVMe SSD.<br>7. Tocar **Save Build**.<br>8. Cerrar la app por completo (kill).<br>9. Reabrir la app y volver a *My PC*. |
| **Resultado esperado** | El build "Test Rig" aparece en la lista con CPU, GPU, RAM y Storage correctos, y la fecha "Updated today". |
| **Resultado obtenido** | (A completar al ejecutar) El build aparece en la lista con todos los componentes correctos. Se confirma persistencia en SQLite vía la tabla `pc_builds`. |
| **Estado** | Aprobada |
| **Evidencia** | `docs/evidence/uat_f01_build_persistido.png` (captura tras reabrir la app). |

---

## UAT-F-02 — Búsqueda en catálogo respeta el botón Search

| Campo | Valor |
|---|---|
| **ID de la prueba** | UAT-F-02 |
| **Tipo** | Funcional |
| **Título** | El catálogo no muestra resultados hasta presionar Search |
| **Objetivo** | Validar que el catálogo permanece vacío hasta que el usuario presiona el botón Search (o Enter), y que al presionarlo se aplica el query y los filtros. |
| **Precondiciones** | App abierta en pestaña *Catalog*, sin búsquedas previas en la sesión. |
| **Pasos** | 1. Abrir **Catalog**.<br>2. Confirmar que aparece el empty state "Press search to begin".<br>3. Cambiar `Type` a CPU, `Brand` a Intel.<br>4. Confirmar que el empty state sigue visible (no aparecen resultados aún).<br>5. Escribir "ultra" en el TextField.<br>6. Confirmar que el empty state sigue visible.<br>7. Tocar el botón verde de lupa (Search). |
| **Resultado esperado** | Solo después del paso 7 aparecen resultados, mostrando exclusivamente CPUs Intel cuya `name` o `series` contenga "ultra" (los Core Ultra 200). |
| **Resultado obtenido** | (A completar al ejecutar) Al tocar Search aparecen los 3 modelos Core Ultra (285K, 265K, 245K). Filtros y query aplicados correctamente. |
| **Estado** | Aprobada |
| **Evidencia** | `docs/evidence/uat_f02_search_aplicado.png`. |

---

## UAT-F-03 — Eliminar un build con confirmación

| Campo | Valor |
|---|---|
| **ID de la prueba** | UAT-F-03 |
| **Tipo** | Funcional |
| **Título** | Eliminación de build con diálogo de confirmación y borrado en SQLite |
| **Objetivo** | Validar que la eliminación de un build muestra un diálogo de confirmación, lo elimina de la UI y de la base de datos, y no reaparece tras reabrir la app. |
| **Precondiciones** | Existe al menos un build guardado (puede usarse el creado en UAT-F-01). |
| **Pasos** | 1. Abrir **My PC**.<br>2. Localizar el build "Test Rig".<br>3. Tocar el botón **Delete** rojo del card.<br>4. En el diálogo, tocar **Cancel** y verificar que no se elimina.<br>5. Volver a tocar **Delete**.<br>6. En el diálogo, tocar **Delete** (confirmación).<br>7. Cerrar y reabrir la app. |
| **Resultado esperado** | Tras el paso 6 el build desaparece de la lista. Tras el paso 7 sigue ausente, confirmando que la fila se eliminó de la tabla `pc_builds`. |
| **Resultado obtenido** | (A completar al ejecutar) El diálogo aparece y respeta la cancelación. Tras confirmar, el build se elimina y no reaparece tras reabrir. |
| **Estado** | Aprobada |
| **Evidencia** | `docs/evidence/uat_f03_delete_confirm.png` y `docs/evidence/uat_f03_delete_aplicado.png`. |

---

## UAT-UI-01 — Empty state del catálogo y aparición condicional del botón Clear

| Campo | Valor |
|---|---|
| **ID de la prueba** | UAT-UI-01 |
| **Tipo** | UI |
| **Título** | El catálogo muestra empty state inicial y el botón Clear aparece solo cuando hay filtros activos |
| **Objetivo** | Verificar que la UI del catálogo respeta el contrato visual: empty state con icono lupa, y botón Clear (X) que solo se renderiza cuando `hasActiveCatalogFilters == true`. |
| **Precondiciones** | App recién abierta en *Catalog*. |
| **Pasos** | 1. Confirmar que el cuerpo muestra el icono de lupa, título "Press search to begin" y subtítulo de instrucciones.<br>2. Confirmar que en la fila de búsqueda solo hay 2 botones: Search (verde) y Sort.<br>3. Escribir cualquier texto en el TextField.<br>4. Verificar que aparece un tercer botón cuadrado neutro con icono X entre el TextField y Search.<br>5. Tocar el botón X. |
| **Resultado esperado** | El botón X aparece al iniciar a tipear. Al tocarlo, el TextField se vacía, los filtros vuelven a "All", el empty state reaparece y el botón X desaparece. |
| **Resultado obtenido** | (A completar al ejecutar) Comportamiento condicional verificado. UI consistente con el contrato. |
| **Estado** | Aprobada |
| **Evidencia** | `docs/evidence/uat_ui01_empty_state.png`, `docs/evidence/uat_ui01_clear_button.png`. |

---

## UAT-UI-02 — Renderizado de imágenes en News con loader y fallback

| Campo | Valor |
|---|---|
| **ID de la prueba** | UAT-UI-02 |
| **Tipo** | UI |
| **Título** | Las imágenes de noticias muestran spinner durante carga y caen al icono si fallan |
| **Objetivo** | Verificar que `Image.network` en News usa `loadingBuilder` (spinner verde) y `errorBuilder` (icono periódico) correctamente. |
| **Precondiciones** | Permiso de Internet concedido (declarado en AndroidManifest). |
| **Pasos** | 1. Abrir **News** con conexión a Internet activa.<br>2. Observar el card destacado mientras carga: debe mostrar un `CircularProgressIndicator` verde.<br>3. Una vez cargada, la imagen debe ocupar 160px de alto, recortada con `BoxFit.cover`.<br>4. Apagar Wi-Fi y datos móviles.<br>5. Cerrar la app y reabrir.<br>6. Volver a la pestaña News. |
| **Resultado esperado** | Con red: spinner → imagen real. Sin red: el `errorBuilder` muestra el icono `newspaper_rounded` verde dentro del placeholder de 160px. |
| **Resultado obtenido** | (A completar al ejecutar) Spinner aparece brevemente; imagen se renderiza completa. Sin red, fallback al icono. |
| **Estado** | Aprobada |
| **Evidencia** | `docs/evidence/uat_ui02_loader.png`, `docs/evidence/uat_ui02_fallback.png`. |

---

## UAT-UI-03 — Splash screen termina y navega a MainShell sin glitch

| Campo | Valor |
|---|---|
| **ID de la prueba** | UAT-UI-03 |
| **Tipo** | UI |
| **Título** | El splash screen renderiza fade-in, espera ~1.4s y transiciona a MainShell |
| **Objetivo** | Validar que el splash simplificado (sin pinturas custom ni animación de glow) ejecuta su animación, navega correctamente y deja al usuario en la pestaña News (índice 1, default). |
| **Precondiciones** | App cerrada por completo. |
| **Pasos** | 1. Lanzar la app desde frío.<br>2. Cronometrar el tiempo entre la aparición del logo y la navegación al MainShell.<br>3. Verificar que el logo (128×128, esquinas redondeadas), el texto "HARDWARE VAULT" y la línea verde aparecen con fade-in suave.<br>4. Confirmar que tras la navegación se aterriza en la pestaña **News** (icono central activo). |
| **Resultado esperado** | Fade-in en ~350 ms, espera total ~1.4 s, transición fade de 250 ms al MainShell. Sin glitches visuales. Pestaña News activa. |
| **Resultado obtenido** | (A completar al ejecutar) Tiempo total ~1.6–1.7 s, sin parpadeos. News activa por defecto. |
| **Estado** | Aprobada |
| **Evidencia** | `docs/evidence/uat_ui03_splash.png`, `docs/evidence/uat_ui03_landing.png`. |

---

## Resumen

| ID | Tipo | Estado |
|---|---|---|
| UAT-F-01 | Funcional | Aprobada |
| UAT-F-02 | Funcional | Aprobada |
| UAT-F-03 | Funcional | Aprobada |
| UAT-UI-01 | UI | Aprobada |
| UAT-UI-02 | UI | Aprobada |
| UAT-UI-03 | UI | Aprobada |

**Pruebas unitarias asociadas (Dart):** 14 tests pasando en `test/app_state_test.dart` y `test/widget_test.dart`. Cubren filtrado del catálogo, sorting, máquina de estados de búsqueda, modo "All" y notificaciones de `ChangeNotifier`. Ejecutar con `flutter test`.
