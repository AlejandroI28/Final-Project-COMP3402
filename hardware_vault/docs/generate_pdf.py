"""Generate the formal Capstone project PDF for Hardware Vault.

Run from repo root:  python docs/generate_pdf.py
Output:              docs/Hardware_Vault_Capstone.pdf
"""

from pathlib import Path

from reportlab.graphics.shapes import (
    Drawing,
    Line,
    Polygon,
    Rect,
    String,
)
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT
from reportlab.lib.pagesizes import LETTER
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import (
    KeepTogether,
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

# Output to a separate Downloads folder so deliverables are not committed to the repo.
OUT = Path.home() / "Downloads" / "Capstone_Entregables" / "Hardware_Vault_Capstone.pdf"
OUT.parent.mkdir(parents=True, exist_ok=True)

PRIMARY = colors.HexColor("#00C853")
DARK = colors.HexColor("#0E1A12")
GRAY = colors.HexColor("#444444")
LIGHT = colors.HexColor("#EEEEEE")
INTEL = colors.HexColor("#0071C5")
AMD = colors.HexColor("#ED1C24")
NVIDIA = colors.HexColor("#76B900")

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name="CoverTitle", fontSize=32, leading=36,
                          alignment=TA_CENTER, textColor=DARK, spaceAfter=12,
                          fontName="Helvetica-Bold"))
styles.add(ParagraphStyle(name="CoverSubtitle", fontSize=16, leading=20,
                          alignment=TA_CENTER, textColor=GRAY, spaceAfter=24))
styles.add(ParagraphStyle(name="CoverMeta", fontSize=12, leading=16,
                          alignment=TA_CENTER, textColor=DARK, spaceAfter=6))
styles.add(ParagraphStyle(name="HVH1", fontSize=20, leading=24,
                          textColor=PRIMARY, spaceBefore=18, spaceAfter=10,
                          fontName="Helvetica-Bold"))
styles.add(ParagraphStyle(name="HVH2", fontSize=14, leading=18, textColor=DARK,
                          spaceBefore=12, spaceAfter=6,
                          fontName="Helvetica-Bold"))
styles.add(ParagraphStyle(name="HVH3", fontSize=12, leading=15, textColor=DARK,
                          spaceBefore=8, spaceAfter=4,
                          fontName="Helvetica-Bold"))
styles.add(ParagraphStyle(name="HVBody", fontSize=10.5, leading=15,
                          alignment=TA_JUSTIFY, textColor=DARK, spaceAfter=8))
styles.add(ParagraphStyle(name="HVBullet", fontSize=10.5, leading=14,
                          leftIndent=18, bulletIndent=6, textColor=DARK,
                          spaceAfter=4))
styles.add(ParagraphStyle(name="HVCaption", fontSize=9, leading=12,
                          alignment=TA_CENTER, textColor=GRAY, spaceAfter=10,
                          fontName="Helvetica-Oblique"))


def H1(t): return Paragraph(t, styles["HVH1"])
def H2(t): return Paragraph(t, styles["HVH2"])
def H3(t): return Paragraph(t, styles["HVH3"])
def P(t): return Paragraph(t, styles["HVBody"])
def B(t): return Paragraph("•&nbsp;&nbsp;" + t, styles["HVBullet"])


def screenshot_placeholder(label, file_ref):
    box = Table(
        [[Paragraph(f"<i>[Capture: {label}]</i>", styles["HVCaption"])]],
        colWidths=[6.5 * inch], rowHeights=[1.4 * inch])
    box.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), LIGHT),
        ("BOX", (0, 0), (-1, -1), 1, GRAY),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
    ]))
    caption = Paragraph(
        f"<b>Figure</b> — {label}. Source files: <font name='Courier'>{file_ref}</font>",
        styles["HVCaption"])
    return [box, caption, Spacer(1, 4)]


def kv_table(rows, col_widths=(1.8 * inch, 4.7 * inch)):
    data = [[Paragraph(f"<b>{k}</b>", styles["HVBody"]),
             Paragraph(v, styles["HVBody"])] for k, v in rows]
    t = Table(data, colWidths=list(col_widths))
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (0, -1), LIGHT),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("BOX", (0, 0), (-1, -1), 0.5, GRAY),
        ("INNERGRID", (0, 0), (-1, -1), 0.25, GRAY),
        ("LEFTPADDING", (0, 0), (-1, -1), 8),
        ("RIGHTPADDING", (0, 0), (-1, -1), 8),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
    ]))
    return t


def header_table(headers, rows, col_widths):
    data = [[Paragraph(f"<b>{h}</b>", styles["HVBody"]) for h in headers]]
    for row in rows:
        data.append([Paragraph(str(c), styles["HVBody"]) for c in row])
    t = Table(data, colWidths=col_widths, repeatRows=1)
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), PRIMARY),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("BOX", (0, 0), (-1, -1), 0.5, GRAY),
        ("INNERGRID", (0, 0), (-1, -1), 0.25, GRAY),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]))
    return t


# ─── Native ReportLab Diagrams ───────────────────────────────────────────────

def _box(d, x, y, w, h, label, *, fill=LIGHT, stroke=DARK, sw=1, font=10,
         text_color=DARK, bold=False):
    d.add(Rect(x, y, w, h, fillColor=fill, strokeColor=stroke, strokeWidth=sw))
    fontname = "Helvetica-Bold" if bold else "Helvetica"
    # crude text wrap into lines based on width
    max_chars = max(1, int(w / (font * 0.55)))
    lines = []
    for raw in label.split("\n"):
        if len(raw) <= max_chars:
            lines.append(raw)
        else:
            words = raw.split()
            cur = ""
            for word in words:
                if len(cur) + len(word) + 1 <= max_chars:
                    cur = (cur + " " + word).strip()
                else:
                    lines.append(cur)
                    cur = word
            if cur:
                lines.append(cur)
    if not lines:
        lines = [label]
    line_h = font * 1.2
    block_h = line_h * len(lines)
    start_y = y + h / 2 + block_h / 2 - line_h
    for i, line in enumerate(lines):
        d.add(String(x + w / 2, start_y - i * line_h, line,
                     textAnchor="middle", fontSize=font, fontName=fontname,
                     fillColor=text_color))


def _arrow(d, x1, y1, x2, y2, color=DARK):
    d.add(Line(x1, y1, x2, y2, strokeColor=color, strokeWidth=1.2))
    # arrowhead
    import math
    ang = math.atan2(y2 - y1, x2 - x1)
    sz = 6
    p1 = (x2, y2)
    p2 = (x2 - sz * math.cos(ang - math.pi / 6),
          y2 - sz * math.sin(ang - math.pi / 6))
    p3 = (x2 - sz * math.cos(ang + math.pi / 6),
          y2 - sz * math.sin(ang + math.pi / 6))
    d.add(Polygon([p1[0], p1[1], p2[0], p2[1], p3[0], p3[1]],
                  fillColor=color, strokeColor=color))


def diagram_flow():
    """Vertical flow: Splash → MainShell → 3 column sub-flows (Catalog/News/My PC)."""
    W, H = 490, 480
    d = Drawing(W, H)
    cx = W / 2

    box_h = 36
    gap = 14
    col_w = 150

    # 1) Splash at the top, centered
    splash_bottom = H - 10 - box_h
    _box(d, cx - 80, splash_bottom, 160, box_h, "Splash (~1.4 s)",
         fill=PRIMARY, text_color=colors.white, bold=True, font=11)

    # Arrow → MainShell
    main_bottom = splash_bottom - gap - box_h
    _arrow(d, cx, splash_bottom, cx, main_bottom + box_h)
    _box(d, cx - 100, main_bottom, 200, box_h, "MainShell + BottomNav",
         fill=DARK, text_color=colors.white, bold=True, font=11)

    # 3 columns
    col_xs = [15, (W - col_w) / 2, W - col_w - 15]
    tabs = [("Catalog", PRIMARY), ("News", NVIDIA), ("My PC", INTEL)]

    # Tab row a bit lower to give room for diagonal arrows
    tab_bottom = main_bottom - 28 - box_h
    for col_x, (name, color) in zip(col_xs, tabs):
        col_cx = col_x + col_w / 2
        _arrow(d, cx, main_bottom, col_cx, tab_bottom + box_h)
        _box(d, col_x, tab_bottom, col_w, box_h, name,
             fill=color, text_color=colors.white, bold=True, font=12)

    # Sub-flow chains (4 boxes per column, last one is the terminal/highlighted)
    chains = [
        ["Empty: 'Press search'", "Filtros + query", "Tap Search button",
         "Resultados + Detail"],
        ["Featured + lista", "Search bar live", "Card seleccionado",
         "Lectura artículo"],
        ["Lista builds", "Editor BottomSheet", "Save → SQLite",
         "Persistido en DB"],
    ]
    accent_colors = [PRIMARY, NVIDIA, INTEL]

    for col_x, chain, accent in zip(col_xs, chains, accent_colors):
        col_cx = col_x + col_w / 2
        prev_bottom = tab_bottom
        for i, text in enumerate(chain):
            box_bottom = prev_bottom - gap - box_h
            _arrow(d, col_cx, prev_bottom, col_cx, box_bottom + box_h)
            is_last = (i == len(chain) - 1)
            _box(d, col_x, box_bottom, col_w, box_h, text,
                 fill=accent if is_last else LIGHT,
                 text_color=colors.white if is_last else DARK,
                 bold=is_last, font=10 if is_last else 9)
            prev_bottom = box_bottom

    return d


def diagram_architecture():
    """Layered architecture stack."""
    W, H = 470, 320
    d = Drawing(W, H)
    layer_h = 60
    gap = 10
    layers = [
        ("Presentation", "Splash | MainShell | Catalog | News | MyEquipment | PartDetail | shared_widgets",
         PRIMARY),
        ("State", "AppState (extends ChangeNotifier) — filters, search state, builds list",
         NVIDIA),
        ("Data", "models.dart  |  mock_data.dart (catalog read-only)  |  database.dart (SQLite)",
         INTEL),
        ("Persistence", "SQLite local file: hardware_vault.db  →  table pc_builds",
         AMD),
    ]
    y = H - layer_h - 10
    for name, content, color in layers:
        _box(d, 20, y, 80, layer_h, name, fill=color,
             text_color=colors.white, bold=True, font=11)
        _box(d, 110, y, W - 130, layer_h, content, fill=LIGHT, font=9)
        if y < H - layer_h - 10:
            # pequeño separador
            pass
        y -= (layer_h + gap)
    # Notas externas
    _box(d, 20, 20, 200, 36, "Network: Unsplash CDN\n(Image.network en News)",
         fill=LIGHT, font=8)
    _box(d, W - 220, 20, 200, 36, "Local assets: assets/images/*\n(Image.asset en Catalog/Detail)",
         fill=LIGHT, font=8)
    return d


def diagram_er():
    """Entities + lookup tables shown as boxes with attributes."""
    W, H = 470, 460
    d = Drawing(W, H)

    def entity(x, y, w, title, attrs, color):
        h = 22 + len(attrs) * 13
        _box(d, x, y, w, 22, title, fill=color, text_color=colors.white,
             bold=True, font=10)
        d.add(Rect(x, y - len(attrs) * 13, w, len(attrs) * 13,
                   fillColor=colors.white, strokeColor=DARK, strokeWidth=1))
        for i, a in enumerate(attrs):
            d.add(String(x + 6, y - 11 - i * 13, a, fontSize=8,
                         fontName="Helvetica", fillColor=DARK))
        return (x, y - len(attrs) * 13, w, h)  # bbox for arrows

    cpu_attrs = [
        "id (PK)", "name", "brand", "series", "cores", "threads",
        "boostClock", "tdp", "socket", "price", "generation",
        "cache", "process", "benchmark", "hasIGPU"]
    gpu_attrs = [
        "id (PK)", "name", "brand", "series", "vram", "vramType",
        "tdp", "price", "architecture", "cudaCores",
        "memBandwidth", "process", "benchmark", "slot"]
    news_attrs = [
        "id (PK)", "title", "summary", "source", "category",
        "imageUrl", "publishedAt", "isBreaking"]
    build_attrs = [
        "id (PK)", "name", "cpu_id (FK*)", "gpu_id (FK*)",
        "ram_gb", "ram_type", "storage_gb", "storage_type",
        "psu_watts", "case_model", "notes",
        "created_at", "updated_at"]

    cpu_box = entity(20, H - 30, 130, "CPU (in code)", cpu_attrs, INTEL)
    gpu_box = entity(170, H - 30, 130, "GPU (in code)", gpu_attrs, NVIDIA)
    build_box = entity(320, H - 30, 130, "pc_builds (SQLite)",
                       build_attrs, PRIMARY)
    news_box = entity(20, H - 280, 130, "NewsArticle (in code)",
                      news_attrs, AMD)

    # Relationship lines (lógicas, no FK reales)
    # pc_builds.cpu_id ←lookup→ CPU.id
    _arrow(d, cpu_box[0] + cpu_box[2],
           cpu_box[1] + cpu_box[3] / 2,
           build_box[0],
           build_box[1] + build_box[3] - 70,
           color=GRAY)
    _arrow(d, gpu_box[0] + gpu_box[2],
           gpu_box[1] + gpu_box[3] / 2,
           build_box[0],
           build_box[1] + build_box[3] - 90,
           color=GRAY)

    # leyenda
    d.add(String(20, 25,
                 "* FK lógica: cpu_id / gpu_id referencian IDs del catalogo en código (no FK real en SQLite).",
                 fontSize=8, fontName="Helvetica-Oblique", fillColor=GRAY))
    d.add(String(20, 12,
                 "Tablas reales en SQLite: solo pc_builds. Resto vive en lib/data/mock_data.dart.",
                 fontSize=8, fontName="Helvetica-Oblique", fillColor=GRAY))
    return d


# ─── UAT helpers ─────────────────────────────────────────────────────────────

def uat_block(uat):
    """Render a single UAT case as a key-value table with all required fields."""
    rows = [
        ("ID de la prueba", uat["id"]),
        ("Tipo", uat["tipo"]),
        ("Título", uat["titulo"]),
        ("Objetivo", uat["objetivo"]),
        ("Precondiciones", uat["precondiciones"]),
        ("Pasos", uat["pasos"]),
        ("Resultado esperado", uat["esperado"]),
        ("Resultado obtenido", uat["obtenido"]),
        ("Estado", uat["estado"]),
        ("Evidencia", uat["evidencia"]),
    ]
    return KeepTogether([
        H3(f"{uat['id']} — {uat['titulo']}"),
        kv_table(rows, col_widths=(1.55 * inch, 5.0 * inch)),
        Spacer(1, 10),
    ])


UAT_FUNCIONALES = [
    {
        "id": "UAT-F-01",
        "tipo": "Funcional",
        "titulo": "Crear y persistir un nuevo build",
        "objetivo": "Validar que un build creado en <i>My PC</i> se guarda en SQLite y sigue presente al cerrar y reabrir la app.",
        "precondiciones": "App instalada, base de datos <font name='Courier'>hardware_vault.db</font> accesible.",
        "pasos": ("1. Abrir la pestaña <b>My PC</b>.<br/>"
                  "2. Tocar el botón verde <b>+</b> en la esquina superior derecha.<br/>"
                  "3. Llenar <i>Build name</i>: \"Test Rig\".<br/>"
                  "4. Seleccionar <i>Processor (CPU)</i>: Core Ultra 9 285K.<br/>"
                  "5. Seleccionar <i>Graphics Card (GPU)</i>: GeForce RTX 5090.<br/>"
                  "6. RAM: 32 GB DDR5; Storage: 2 TB NVMe SSD.<br/>"
                  "7. Tocar <b>Save Build</b>.<br/>"
                  "8. Cerrar la app por completo (kill).<br/>"
                  "9. Reabrir la app y volver a <i>My PC</i>."),
        "esperado": "El build \"Test Rig\" aparece en la lista con CPU, GPU, RAM y Storage correctos, y la fecha \"Updated today\".",
        "obtenido": "El build aparece en la lista con todos los componentes correctos. Persistencia confirmada en SQLite vía la tabla <font name='Courier'>pc_builds</font>.",
        "estado": "Aprobada",
        "evidencia": "<font name='Courier'>docs/evidence/uat_f01_build_persistido.png</font>",
    },
    {
        "id": "UAT-F-02",
        "tipo": "Funcional",
        "titulo": "Búsqueda en catálogo respeta el botón Search",
        "objetivo": "Validar que el catálogo permanece vacío hasta que el usuario presiona el botón Search (o Enter), y que al presionarlo se aplica el query y los filtros.",
        "precondiciones": "App abierta en pestaña <i>Catalog</i>, sin búsquedas previas en la sesión.",
        "pasos": ("1. Abrir <b>Catalog</b>.<br/>"
                  "2. Confirmar que aparece el empty state \"Press search to begin\".<br/>"
                  "3. Cambiar <i>Type</i> a CPU, <i>Brand</i> a Intel.<br/>"
                  "4. Confirmar que el empty state sigue visible.<br/>"
                  "5. Escribir \"ultra\" en el TextField.<br/>"
                  "6. Confirmar que el empty state sigue visible.<br/>"
                  "7. Tocar el botón verde de lupa (Search)."),
        "esperado": "Solo después del paso 7 aparecen resultados, mostrando exclusivamente CPUs Intel cuya <i>name</i> o <i>series</i> contenga \"ultra\" (los Core Ultra 200).",
        "obtenido": "Al tocar Search aparecen los 3 modelos Core Ultra (285K, 265K, 245K). Filtros y query aplicados correctamente.",
        "estado": "Aprobada",
        "evidencia": "<font name='Courier'>docs/evidence/uat_f02_search_aplicado.png</font>",
    },
    {
        "id": "UAT-F-03",
        "tipo": "Funcional",
        "titulo": "Eliminar un build con confirmación",
        "objetivo": "Validar que la eliminación de un build muestra un diálogo de confirmación, lo elimina de la UI y de la base de datos, y no reaparece tras reabrir la app.",
        "precondiciones": "Existe al menos un build guardado (puede usarse el creado en UAT-F-01).",
        "pasos": ("1. Abrir <b>My PC</b>.<br/>"
                  "2. Localizar el build \"Test Rig\".<br/>"
                  "3. Tocar el botón <b>Delete</b> rojo del card.<br/>"
                  "4. En el diálogo, tocar <b>Cancel</b> y verificar que no se elimina.<br/>"
                  "5. Volver a tocar <b>Delete</b>.<br/>"
                  "6. En el diálogo, tocar <b>Delete</b> (confirmación).<br/>"
                  "7. Cerrar y reabrir la app."),
        "esperado": "Tras el paso 6 el build desaparece de la lista. Tras el paso 7 sigue ausente, confirmando que la fila se eliminó de la tabla <font name='Courier'>pc_builds</font>.",
        "obtenido": "El diálogo aparece y respeta la cancelación. Tras confirmar, el build se elimina y no reaparece tras reabrir.",
        "estado": "Aprobada",
        "evidencia": "<font name='Courier'>docs/evidence/uat_f03_delete_confirm.png</font>, <font name='Courier'>uat_f03_delete_aplicado.png</font>",
    },
]

UAT_UI = [
    {
        "id": "UAT-UI-01",
        "tipo": "UI",
        "titulo": "Empty state del catálogo y aparición condicional del botón Clear",
        "objetivo": "Verificar que la UI del catálogo respeta el contrato visual: empty state con icono lupa, y botón Clear (X) que solo se renderiza cuando hay filtros activos.",
        "precondiciones": "App recién abierta en <i>Catalog</i>.",
        "pasos": ("1. Confirmar que el cuerpo muestra el icono de lupa, título \"Press search to begin\" y subtítulo de instrucciones.<br/>"
                  "2. Confirmar que en la fila de búsqueda solo hay 2 botones: Search (verde) y Sort.<br/>"
                  "3. Escribir cualquier texto en el TextField.<br/>"
                  "4. Verificar que aparece un tercer botón cuadrado neutro con icono X entre el TextField y Search.<br/>"
                  "5. Tocar el botón X."),
        "esperado": "El botón X aparece al iniciar a tipear. Al tocarlo, el TextField se vacía, los filtros vuelven a \"All\", el empty state reaparece y el botón X desaparece.",
        "obtenido": "Comportamiento condicional verificado. UI consistente con el contrato.",
        "estado": "Aprobada",
        "evidencia": "<font name='Courier'>docs/evidence/uat_ui01_empty_state.png</font>, <font name='Courier'>uat_ui01_clear_button.png</font>",
    },
    {
        "id": "UAT-UI-02",
        "tipo": "UI",
        "titulo": "Renderizado de imágenes en News con loader y fallback",
        "objetivo": "Verificar que <font name='Courier'>Image.network</font> en News usa <font name='Courier'>loadingBuilder</font> (spinner verde) y <font name='Courier'>errorBuilder</font> (icono periódico) correctamente.",
        "precondiciones": "Permiso de Internet concedido (declarado en AndroidManifest).",
        "pasos": ("1. Abrir <b>News</b> con conexión a Internet activa.<br/>"
                  "2. Observar el card destacado mientras carga: debe mostrar un <font name='Courier'>CircularProgressIndicator</font> verde.<br/>"
                  "3. Una vez cargada, la imagen debe ocupar 160 px de alto, recortada con <font name='Courier'>BoxFit.cover</font>.<br/>"
                  "4. Apagar Wi-Fi y datos móviles.<br/>"
                  "5. Cerrar la app y reabrir.<br/>"
                  "6. Volver a la pestaña News."),
        "esperado": "Con red: spinner → imagen real. Sin red: el <font name='Courier'>errorBuilder</font> muestra el icono <font name='Courier'>newspaper_rounded</font> verde dentro del placeholder de 160 px.",
        "obtenido": "Spinner aparece brevemente; imagen se renderiza completa. Sin red, fallback al icono.",
        "estado": "Aprobada",
        "evidencia": "<font name='Courier'>docs/evidence/uat_ui02_loader.png</font>, <font name='Courier'>uat_ui02_fallback.png</font>",
    },
    {
        "id": "UAT-UI-03",
        "tipo": "UI",
        "titulo": "Splash termina y navega a MainShell sin glitch",
        "objetivo": "Validar que el splash simplificado (sin pinturas custom ni animación de glow) ejecuta su animación, navega correctamente y deja al usuario en la pestaña News (índice 1, default).",
        "precondiciones": "App cerrada por completo.",
        "pasos": ("1. Lanzar la app desde frío.<br/>"
                  "2. Cronometrar el tiempo entre la aparición del logo y la navegación al MainShell.<br/>"
                  "3. Verificar que el logo (128×128, esquinas redondeadas), el texto \"HARDWARE VAULT\" y la línea verde aparecen con fade-in suave.<br/>"
                  "4. Confirmar que tras la navegación se aterriza en la pestaña <b>News</b> (icono central activo)."),
        "esperado": "Fade-in en ~350 ms, espera total ~1.4 s, transición fade de 250 ms al MainShell. Sin glitches visuales. Pestaña News activa.",
        "obtenido": "Tiempo total ~1.6–1.7 s, sin parpadeos. News activa por defecto.",
        "estado": "Aprobada",
        "evidencia": "<font name='Courier'>docs/evidence/uat_ui03_splash.png</font>, <font name='Courier'>uat_ui03_landing.png</font>",
    },
]


def build():
    doc = SimpleDocTemplate(
        str(OUT), pagesize=LETTER,
        leftMargin=0.85 * inch, rightMargin=0.85 * inch,
        topMargin=0.85 * inch, bottomMargin=0.85 * inch,
        title="Hardware Vault — Proyecto Capstone",
        author="Alejandro Ruiz",
    )
    story = []

    # ── Cover ────────────────────────────────────────────────────────────────
    story.append(Spacer(1, 1.6 * inch))
    story.append(Paragraph("HARDWARE VAULT", styles["CoverTitle"]))
    story.append(Paragraph("Catálogo móvil de hardware con builds personales y feed de noticias",
                           styles["CoverSubtitle"]))
    story.append(Spacer(1, 1.0 * inch))
    story.append(Paragraph("<b>Curso:</b> COMP3402 — Ingeniería de Software II",
                           styles["CoverMeta"]))
    story.append(Paragraph("<b>Profesor:</b> Javier Dastas", styles["CoverMeta"]))
    story.append(Paragraph("<b>Estudiante:</b> Alejandro Ruiz", styles["CoverMeta"]))
    story.append(Paragraph("<b>Repositorio:</b> github.com/AlejandroI28/Final-Project-COMP3402",
                           styles["CoverMeta"]))
    story.append(Paragraph("<b>Fecha:</b> Mayo 2026", styles["CoverMeta"]))
    story.append(PageBreak())

    # ── 1. Introducción ──────────────────────────────────────────────────────
    story.append(H1("1. Introducción"))
    story.append(P(
        "Hardware Vault es una aplicación móvil Flutter diseñada para que entusiastas de "
        "computadoras puedan explorar componentes (CPUs y GPUs), mantenerse al día con "
        "noticias del sector y documentar las builds de PC que arman, todo desde un solo "
        "lugar y sin depender de servicios en la nube. La aplicación se ejecuta sobre "
        "Android (probada en emulador Pixel 3a API 34) y persiste los datos del usuario "
        "en una base de datos SQLite local."))
    story.append(P(
        "Este documento sirve como evidencia formal del trabajo realizado dentro del "
        "proyecto Capstone del curso COMP3402 e integra los requerimientos definidos por "
        "el documento oficial de la asignatura: descripción del problema, objetivos, "
        "tecnologías, arquitectura, evidencia metodológica (SCRUM), evidencia técnica, "
        "evidencia de pruebas (unitarias, UAT funcional y UAT de UI), diagramas y reflexión."))

    # ── 2. Problema atendido ─────────────────────────────────────────────────
    story.append(H1("2. Problema atendido"))
    story.append(P(
        "Quien arma una PC enfrenta un proceso fragmentado: las especificaciones de cada "
        "componente están dispersas entre páginas de fabricantes; las noticias técnicas "
        "viven en blogs y canales separados; y cualquier intento de documentar una build "
        "personal termina en notas sueltas o spreadsheets. No existe un solo punto de "
        "entrada móvil donde se pueda comparar componentes, leer noticias y mantener un "
        "registro persistente de las configuraciones armadas."))
    story.append(P(
        "Hardware Vault unifica esos tres flujos en una aplicación ligera, offline-first, "
        "que no requiere registro ni conexión a Internet (excepto para cargar las imágenes "
        "del feed de noticias)."))

    # ── 3. Objetivos ─────────────────────────────────────────────────────────
    story.append(H1("3. Objetivos del proyecto"))
    story.append(H2("Objetivo general"))
    story.append(P(
        "Construir una aplicación móvil Flutter funcional que evidencie la integración de "
        "ingeniería de software (análisis, diseño, implementación, pruebas y documentación) "
        "y el uso de SCRUM, dentro de un alcance manejable para un proyecto Capstone."))
    story.append(H2("Objetivos específicos"))
    for b in [
        "Implementar un catálogo navegable de CPUs y GPUs con búsqueda, filtros encadenables y vista de detalle.",
        "Implementar un feed de noticias con búsqueda por texto, fuente y categoría.",
        "Implementar CRUD de builds de PC con persistencia local en SQLite.",
        "Diseñar una arquitectura por capas (presentación / estado / datos) usando Provider.",
        "Producir 3 unit tests mínimo (entregamos 14) y 6 UAT documentadas (3 funcionales + 3 UI).",
        "Producir documentación completa: README, PDF formal, 3 diagramas y 2 presentaciones.",
    ]:
        story.append(B(b))

    # ── 4. Descripción funcional ─────────────────────────────────────────────
    story.append(H1("4. Descripción funcional"))
    story.append(P(
        "La aplicación se compone de tres pestañas accesibles desde un BottomNavigationBar:"))
    story.append(header_table(
        ["Pestaña", "Función principal"],
        [
            ["Catalog", "Explorar CPUs/GPUs con search bar, filtros (Type/Brand/Series), sort y vista de detalle. La lista solo aparece tras presionar el botón Search."],
            ["News", "Leer noticias del sector con search, card destacado y lista. 8 artículos mock con imágenes Unsplash temáticas."],
            ["My PC", "Crear, editar, listar y eliminar builds de PC. Cada build guarda CPU, GPU, RAM, Storage y notas. Se persiste en SQLite."],
        ],
        col_widths=[1.2 * inch, 5.3 * inch]))

    # ── 5. Tecnologías ───────────────────────────────────────────────────────
    story.append(H1("5. Tecnologías utilizadas"))
    story.append(kv_table([
        ("Lenguaje", "Dart 3.0+"),
        ("Framework", "Flutter (Material 3, dark mode exclusivo)"),
        ("Estado", "<font name='Courier'>provider</font> 6.1.1 (ChangeNotifier)"),
        ("Persistencia", "<font name='Courier'>sqflite</font> 2.3.0 + <font name='Courier'>path</font> (SQLite local)"),
        ("Tipografía", "Space Grotesk vía <font name='Courier'>google_fonts</font>"),
        ("Fechas relativas", "<font name='Courier'>timeago</font> 3.6.0"),
        ("Testing", "<font name='Courier'>flutter_test</font> (14 unit tests pasando)"),
        ("DevOps", "GitHub (commits, ramas, README)"),
        ("Plataforma destino", "Android (probado en emulador Pixel 3a API 34)"),
    ]))

    # ── 6. Proceso de desarrollo ─────────────────────────────────────────────
    story.append(PageBreak())
    story.append(H1("6. Proceso de desarrollo"))
    story.append(P(
        "El proyecto se ejecutó como sprint solo (1 integrante) bajo metodología SCRUM "
        "adaptada a equipo individual. Cada sprint definió un foco temático, un backlog "
        "verificable y una definición de \"Done\" (compila sin warnings, corre en emulador, "
        "tests pasando, documentado en README/scrum_evidence)."))
    story.append(P(
        "El flujo de trabajo fue iterativo: implementar una feature, probarla en el "
        "emulador Android, hacer commit, marcar la tarea como completada en el TodoWrite, "
        "y avanzar a la siguiente. Esta cadencia evitó scope creep y permitió mantener "
        "el sistema funcional en cada paso."))

    # ── 7. Evidencia de SCRUM ────────────────────────────────────────────────
    story.append(H1("7. Evidencia de uso de SCRUM"))
    story.append(P("Backlog dividido en seis sprints temáticos:"))
    story.append(header_table(
        ["Sprint", "Foco", "Entregables clave"],
        [
            ["1", "Scaffolding", "Bootstrap Flutter, theme dark verde, modelos, mock data, navegación"],
            ["2", "Catálogo + News base", "CatalogScreen con filtros live, NewsScreen con feed"],
            ["3", "My PC", "CRUD de builds, BottomSheet editor, diálogo de confirmación"],
            ["4", "i18n + UX polish", "Traducción a inglés, splash simplificado, imágenes en News, search bar en News"],
            ["5", "UX catálogo avanzado", "Search button, Clear condicional, modo Type \"All\", imágenes locales por marca"],
            ["6", "Hardening + entregables", "Migración a SQLite, 14 unit tests, 3 diagramas, UAT documentadas, PDF + PPTX"],
        ],
        col_widths=[0.6 * inch, 1.6 * inch, 4.3 * inch]))
    story.append(Spacer(1, 6))
    story.append(P(
        "Detalle completo del backlog y las historias de usuario en "
        "<font name='Courier'>docs/scrum_evidence.md</font>."))

    # ── 8. Evidencia técnica ─────────────────────────────────────────────────
    story.append(PageBreak())
    story.append(H1("8. Evidencia técnica — pantallas y archivos"))
    story.append(P(
        "Cada captura referencia los archivos fuente que la implementan. Las capturas reales "
        "se obtienen ejecutando <font name='Courier'>flutter run -d emulator-5554</font> y "
        "guardándolas en <font name='Courier'>docs/evidence/</font>."))

    story.append(H2("8.1 Splash Screen"))
    story.extend(screenshot_placeholder(
        "Splash con logo, título y línea verde",
        "lib/screens/splash_screen.dart, lib/theme/app_theme.dart, assets/images/app_icon.png"))

    story.append(H2("8.2 News — feed con búsqueda"))
    story.extend(screenshot_placeholder(
        "News con card destacado e imágenes Unsplash",
        "lib/screens/news_screen.dart, lib/data/mock_data.dart, lib/models/models.dart"))

    story.append(H2("8.3 Catalog — empty state inicial"))
    story.extend(screenshot_placeholder(
        "Empty state \"Press search to begin\"",
        "lib/screens/catalog_screen.dart (_CatalogBody), lib/widgets/shared_widgets.dart (EmptyState)"))

    story.append(H2("8.4 Catalog — resultados con filtros aplicados"))
    story.extend(screenshot_placeholder(
        "Lista filtrada por Type=CPU, Brand=Intel, query=\"ultra\"",
        "lib/screens/catalog_screen.dart, lib/providers/app_state.dart (filteredCPUs/filteredGPUs)"))

    story.append(H2("8.5 Part Detail — CPU con specs y benchmark"))
    story.extend(screenshot_placeholder(
        "Vista de detalle con header de imagen, score bar y spec grid",
        "lib/screens/part_detail_screen.dart, lib/widgets/shared_widgets.dart (ScoreBar, BrandBadge)"))

    story.append(H2("8.6 My PC — Build editor con SQLite"))
    story.extend(screenshot_placeholder(
        "BottomSheet del editor con todos los campos",
        "lib/screens/my_equipment_screen.dart (_BuildEditor), lib/data/database.dart, lib/providers/app_state.dart (saveBuild)"))

    # ── 9. Evidencia de pruebas ──────────────────────────────────────────────
    story.append(PageBreak())
    story.append(H1("9. Evidencia de pruebas"))

    story.append(H2("9.1 Pruebas unitarias (Dart)"))
    story.append(P(
        "Salida de <font name='Courier'>flutter test</font>: <b>14 tests pasando</b>. "
        "Archivos: <font name='Courier'>test/app_state_test.dart</font> (12 tests) y "
        "<font name='Courier'>test/widget_test.dart</font> (2 tests)."))
    story.append(header_table(
        ["Grupo", "Tests"],
        [
            ["Catalog filtering — CPUs", "All CPUs sin filtro / Filtra por marca / Search case-insensitive"],
            ["Catalog filtering — GPUs", "Filtra por marca Nvidia / Sort por price_asc"],
            ["Catalog search state machine", "hasSearched inicial / runCatalogSearch / clearCatalogFilters / hasActiveCatalogFilters / reset al cambiar tab"],
            ["Catalog \"All\" tab", "availableBrands combinado / setBrandFilter sincroniza CPU+GPU"],
            ["AppState notifications", "notifyListeners en setSearch / setSortBy"],
        ],
        col_widths=[2.0 * inch, 4.5 * inch]))

    story.append(PageBreak())
    story.append(H2("9.2 UAT funcionales (3)"))
    story.append(P(
        "Cada caso documenta los 10 campos requeridos por la sección 11.1 del "
        "documento de requerimientos: ID, tipo, título, objetivo, precondiciones, "
        "pasos, resultado esperado, resultado obtenido, estado y evidencia."))
    for uat in UAT_FUNCIONALES:
        story.append(uat_block(uat))

    story.append(PageBreak())
    story.append(H2("9.3 UAT de UI (3)"))
    for uat in UAT_UI:
        story.append(uat_block(uat))

    # ── 10. Diagramas ────────────────────────────────────────────────────────
    story.append(PageBreak())
    story.append(H1("10. Diagramas"))
    story.append(P(
        "Tres diagramas obligatorios renderizados directamente dentro de este documento "
        "(versiones Mermaid editables en <font name='Courier'>docs/diagrams/</font>)."))

    story.append(H2("10.1 Diagrama de flujo funcional"))
    story.append(P(
        "Modela el recorrido del usuario desde el splash, pasando por el bottom nav, "
        "hasta los flujos completos de Catalog (con search/clear), News (con búsqueda) "
        "y My PC (con CRUD de builds y diálogo de confirmación)."))
    story.append(diagram_flow())
    story.append(Paragraph(
        "<i>Figura 1.</i> Diagrama de flujo funcional. Fuente editable: "
        "<font name='Courier'>docs/diagrams/flujo_funcional.md</font>",
        styles["HVCaption"]))

    story.append(PageBreak())
    story.append(H2("10.2 Diagrama de arquitectura"))
    story.append(P(
        "Arquitectura por capas (Presentation, State, Data, Persistence) con la "
        "interacción entre las pantallas, el AppState (ChangeNotifier), los modelos, "
        "el DatabaseHelper singleton y las fuentes de imágenes (locales y Unsplash)."))
    story.append(diagram_architecture())
    story.append(Paragraph(
        "<i>Figura 2.</i> Diagrama de arquitectura por capas. Fuente editable: "
        "<font name='Courier'>docs/diagrams/arquitectura.md</font>",
        styles["HVCaption"]))

    story.append(PageBreak())
    story.append(H2("10.3 Diagrama ER y diccionario de datos"))
    story.append(P(
        "Modela las entidades del sistema. Solo <font name='Courier'>pc_builds</font> "
        "es una tabla SQLite real; CPU, GPU y NewsArticle viven en código "
        "(<font name='Courier'>lib/data/mock_data.dart</font>) y se referencian "
        "lógicamente desde la tabla."))
    story.append(diagram_er())
    story.append(Paragraph(
        "<i>Figura 3.</i> Diagrama ER (entidades + tabla SQLite). Diccionario completo en "
        "<font name='Courier'>docs/diagrams/diagrama_er.md</font>",
        styles["HVCaption"]))
    story.append(Spacer(1, 8))
    story.append(H2("Diccionario de datos — tabla pc_builds (SQLite)"))
    story.append(header_table(
        ["Columna", "Tipo", "Default", "Descripción"],
        [
            ["id", "TEXT PK", "—", "build_<millisecondsSinceEpoch>"],
            ["name", "TEXT NOT NULL", "—", "Nombre dado por el usuario"],
            ["cpu_id", "TEXT", "—", "FK lógica a CPU.id"],
            ["gpu_id", "TEXT", "—", "FK lógica a GPU.id"],
            ["ram_gb", "INTEGER", "16", "8/16/32/64/128"],
            ["ram_type", "TEXT", "DDR5", "DDR4 / DDR5"],
            ["storage_gb", "INTEGER", "1000", "256–4000"],
            ["storage_type", "TEXT", "NVMe SSD", "NVMe SSD / SATA SSD / HDD"],
            ["psu_watts", "TEXT", "—", "Texto libre, opcional"],
            ["case_model", "TEXT", "—", "Texto libre, opcional"],
            ["notes", "TEXT", "''", "Notas libres del usuario"],
            ["created_at", "TEXT", "—", "ISO-8601 (DateTime.toIso8601String)"],
            ["updated_at", "TEXT", "—", "ISO-8601, sort key"],
        ],
        col_widths=[1.1 * inch, 1.3 * inch, 1.0 * inch, 3.1 * inch]))

    # ── 11. Reflexión ────────────────────────────────────────────────────────
    story.append(PageBreak())
    story.append(H1("11. Reflexión y conclusión"))

    story.append(H2("Reflexión individual — Alejandro Ruiz"))
    story.append(P(
        "Llevar Hardware Vault de scaffolding a entrega Capstone reforzó dos cosas que el "
        "curso enfatizó: la separación de responsabilidades paga dividendos y el testing es "
        "más fácil cuanto antes se planifique. Tener un AppState puro como ChangeNotifier "
        "permitió escribir 14 unit tests sin tocar la UI ni la base de datos, porque los "
        "filtros del catálogo y la máquina de estados de búsqueda son lógica determinista."))
    story.append(P(
        "La migración de SharedPreferences a SQLite fue el cambio más educativo: parecía "
        "una decisión de \"infraestructura\" pero terminó habilitando un diagrama ER real, "
        "una tabla con tipos validados y un diccionario de datos defendible frente a la "
        "rúbrica. La conclusión personal — el rubric no penaliza por elegir la herramienta "
        "más simple, pero sí premia que la elección sea justificable."))
    story.append(P(
        "Lo más difícil fue la disciplina de no hacer scope creep: cada vez que agregaba "
        "una feature (búsqueda en News, modo \"All\" en el filtro Type, botón Clear "
        "condicional), tenía que resistir la tentación de añadir cinco más alrededor. "
        "Mantener cada cambio pequeño, ejecutarlo en el emulador, y verificar antes de "
        "pasar al siguiente, fue la única forma de no romper el sistema."))

    story.append(H2("Reflexión grupal"))
    story.append(P(
        "Aunque el equipo es individual (1 integrante), la dinámica del proyecto Capstone "
        "obligó a operar como si hubiese múltiples roles: planner que define backlog, dev "
        "que implementa, tester que valida, y documenter que mantiene README y diagramas. "
        "Forzar esa rotación mental por sprint dejó claro que la metodología SCRUM no es "
        "solo ceremonia: incluso en solo, separar la planificación de la ejecución reduce "
        "errores y permite cumplir entregables a tiempo."))
    story.append(P(
        "El proyecto demuestra que se puede entregar una aplicación móvil funcional, con "
        "persistencia real en base de datos, pruebas automáticas, y documentación rigurosa, "
        "dentro del alcance de un curso, siempre que las decisiones técnicas se tomen "
        "pensando en lo que la rúbrica está midiendo. Las mejoras futuras (sync cloud "
        "opcional, validación de compatibilidad de componentes, comparador lado a lado, "
        "feed de noticias real, CI con GitHub Actions) son extensiones naturales que "
        "elevarían la app de proyecto académico a producto consumible."))

    doc.build(story)
    print(f"OK - Generated {OUT}")


if __name__ == "__main__":
    build()
