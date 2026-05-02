from reportlab.lib.pagesizes import LETTER
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_JUSTIFY
from reportlab.lib.units import inch
from reportlab.lib.colors import HexColor, black
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, HRFlowable, KeepTogether
)

OUTPUT = r"C:\Users\Alejandro Ruiz\Downloads\Resume_Alejandro_Ruiz_Reyes.pdf"

ACCENT = HexColor("#C75A14")
DARK = HexColor("#1F2937")
GRAY = HexColor("#4B5563")
LIGHT_GRAY = HexColor("#9CA3AF")

doc = SimpleDocTemplate(
    OUTPUT,
    pagesize=LETTER,
    leftMargin=0.7 * inch,
    rightMargin=0.7 * inch,
    topMargin=0.45 * inch,
    bottomMargin=0.45 * inch,
    title="Resume - Alejandro I. Ruiz Reyes",
    author="Alejandro I. Ruiz Reyes",
)

name_style = ParagraphStyle(
    "Name", fontName="Helvetica-Bold", fontSize=26, leading=30,
    alignment=TA_CENTER, textColor=DARK, spaceAfter=4,
)
name_accent_style = ParagraphStyle(
    "NameAccent", parent=name_style, textColor=ACCENT,
)
contact_style = ParagraphStyle(
    "Contact", fontName="Helvetica", fontSize=10, leading=13,
    alignment=TA_CENTER, textColor=GRAY, spaceAfter=14,
)
section_style = ParagraphStyle(
    "Section", fontName="Helvetica-Bold", fontSize=12.5, leading=15,
    textColor=ACCENT, spaceBefore=6, spaceAfter=1,
    letterSpace=1,
)
body_style = ParagraphStyle(
    "Body", fontName="Helvetica", fontSize=10, leading=13.2,
    alignment=TA_JUSTIFY, textColor=DARK, spaceAfter=3,
)
job_title_style = ParagraphStyle(
    "JobTitle", fontName="Helvetica-Bold", fontSize=11, leading=14,
    textColor=DARK, spaceAfter=0,
)
job_meta_style = ParagraphStyle(
    "JobMeta", fontName="Helvetica-Oblique", fontSize=10, leading=13,
    textColor=GRAY, spaceAfter=3,
)
bullet_style = ParagraphStyle(
    "Bullet", fontName="Helvetica", fontSize=9.8, leading=12.6,
    textColor=DARK, leftIndent=14, bulletIndent=2, spaceAfter=0,
)
edu_title_style = ParagraphStyle(
    "EduTitle", fontName="Helvetica-Bold", fontSize=11, leading=14,
    textColor=DARK,
)
edu_meta_style = ParagraphStyle(
    "EduMeta", fontName="Helvetica-Oblique", fontSize=10, leading=13,
    textColor=GRAY,
)


def section_header(text):
    return [
        Paragraph(text.upper(), section_style),
        HRFlowable(width="100%", thickness=1.2, color=ACCENT,
                   spaceBefore=1, spaceAfter=4),
    ]


def bullet(text):
    return Paragraph(f"&bull;&nbsp;&nbsp;{text}", bullet_style)


story = []

# Header
story.append(Paragraph(
    'Alejandro I. <font color="#C75A14">Ruiz Reyes</font>',
    name_style
))
story.append(Paragraph(
    "787-472-1906 &nbsp;&nbsp;|&nbsp;&nbsp; Alejandroiruiz28@gmail.com &nbsp;&nbsp;|&nbsp;&nbsp; Puerto Rico",
    contact_style
))

# Perfil
story.extend(section_header("Perfil Profesional"))
story.append(Paragraph(
    "Bachiller en Ciencias en Computadoras con experiencia académica y profesional en "
    "programación, desarrollo web y manejo de datos. Cuento con un amplio dominio en "
    "hardware de computadoras, incluyendo ensamblaje, configuración y optimización de "
    "componentes. Me distingo por mi pensamiento lógico orientado a la resolución de "
    "problemas complejos, adaptabilidad técnica y compromiso constante con el aprendizaje "
    "de tecnologías emergentes. Busco continuar desarrollándome profesionalmente "
    "aportando soluciones efectivas mediante el uso de la tecnología.",
    body_style
))

# Educación
story.extend(section_header("Educación"))

edu1 = Table(
    [[Paragraph("Bachillerato en Ciencias en Computadoras", edu_title_style),
      Paragraph("Enero 2022 – 2026", edu_meta_style)]],
    colWidths=[4.5 * inch, 2.5 * inch],
)
edu1.setStyle(TableStyle([
    ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ("ALIGN", (1, 0), (1, 0), "RIGHT"),
    ("LEFTPADDING", (0, 0), (-1, -1), 0),
    ("RIGHTPADDING", (0, 0), (-1, -1), 0),
    ("TOPPADDING", (0, 0), (-1, -1), 0),
    ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
]))
story.append(edu1)
story.append(Paragraph(
    "Universidad Interamericana de Puerto Rico, Recinto de Arecibo",
    edu_meta_style
))
story.append(Spacer(1, 3))
story.append(Paragraph(
    "<b>Cursos relevantes:</b> Bases de Datos, Desarrollo Back-End, UX/UI, "
    "Metodologías de Manejo de Proyectos, Programación Orientada a Objetos, "
    "Programación Móvil, Gráficas por Computadora y Estructura de Datos.",
    body_style
))
story.append(Spacer(1, 6))

edu2 = Table(
    [[Paragraph("Grado Técnico en Mecánica Automotriz Avanzada", edu_title_style),
      Paragraph("2019", edu_meta_style)]],
    colWidths=[4.5 * inch, 2.5 * inch],
)
edu2.setStyle(TableStyle([
    ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ("ALIGN", (1, 0), (1, 0), "RIGHT"),
    ("LEFTPADDING", (0, 0), (-1, -1), 0),
    ("RIGHTPADDING", (0, 0), (-1, -1), 0),
    ("TOPPADDING", (0, 0), (-1, -1), 0),
    ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
]))
story.append(edu2)
story.append(Paragraph(
    "Automeca Technical College",
    edu_meta_style
))
story.append(Spacer(1, 6))

edu3 = Table(
    [[Paragraph("Diploma de Escuela Superior", edu_title_style),
      Paragraph("2017", edu_meta_style)]],
    colWidths=[4.5 * inch, 2.5 * inch],
)
edu3.setStyle(TableStyle([
    ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ("ALIGN", (1, 0), (1, 0), "RIGHT"),
    ("LEFTPADDING", (0, 0), (-1, -1), 0),
    ("RIGHTPADDING", (0, 0), (-1, -1), 0),
    ("TOPPADDING", (0, 0), (-1, -1), 0),
    ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
]))
story.append(edu3)
story.append(Paragraph(
    "Escuela Superior Padre Aníbal Reyes Belén, Hatillo, PR",
    edu_meta_style
))

# Experiencia
story.extend(section_header("Experiencia Profesional"))


def job(title, company, location, dates, bullets):
    blocks = []
    header = Table(
        [[Paragraph(f"{title} &mdash; <font color='#C75A14'>{company}</font>", job_title_style),
          Paragraph(dates, edu_meta_style)]],
        colWidths=[4.7 * inch, 2.3 * inch],
    )
    header.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("ALIGN", (1, 0), (1, 0), "RIGHT"),
        ("LEFTPADDING", (0, 0), (-1, -1), 0),
        ("RIGHTPADDING", (0, 0), (-1, -1), 0),
        ("TOPPADDING", (0, 0), (-1, -1), 0),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
    ]))
    blocks.append(header)
    blocks.append(Paragraph(location, job_meta_style))
    for b in bullets:
        blocks.append(bullet(b))
    blocks.append(Spacer(1, 4))
    return KeepTogether(blocks)


story.append(job(
    "Programador y Data Entry",
    "Unique Consulting Group",
    "Puerto Rico",
    "Marzo 2025 – Actualmente",
    [
        "Desarrollo y mantenimiento de soluciones de programación adaptadas a las necesidades del proyecto.",
        "Ingreso, validación y procesamiento de datos en sistemas internos asegurando precisión e integridad.",
        "Colaboración con el equipo en la optimización de procesos digitales y mejora continua de flujos de trabajo.",
    ],
))

story.append(job(
    "Representante de Servicios",
    "Office Max",
    "Hatillo, PR",
    "Enero 2023 – Febrero 2025",
    [
        "Asistencia técnica básica a clientes en equipos y productos tecnológicos.",
        "Manejo de sistemas computarizados y transacciones electrónicas.",
        "Servicio al cliente enfocado en brindar soluciones rápidas y efectivas.",
    ],
))

story.append(job(
    "Representante de Servicios",
    "AutoZone",
    "Arecibo, PR",
    "Enero 2020 – Diciembre 2021",
    [
        "Atención directa al cliente y manejo de inventario digital.",
        "Uso de sistemas computarizados para facturación y consultas técnicas.",
        "Desarrollo de habilidades de comunicación y responsabilidad laboral.",
    ],
))

# Habilidades
story.extend(section_header("Habilidades"))

skills_tech = [
    "Programación: Python, C++, C#, SQL, JavaScript",
    "Manejo de bases de datos",
    "Creación de modelos 3D",
    "Análisis estadístico",
    "Elaboración de informes y visualización de datos",
]
skills_prof = [
    "Trabajo en equipo",
    "Comunicación efectiva (oral y escrita)",
    "Flexibilidad y adaptabilidad",
    "Organización",
    "Ética profesional",
]

skill_header_style = ParagraphStyle(
    "SkillHeader", fontName="Helvetica-Bold", fontSize=10.5, leading=13,
    textColor=DARK, spaceAfter=2,
)
skill_item_style = ParagraphStyle(
    "SkillItem", fontName="Helvetica", fontSize=10, leading=13.5,
    textColor=DARK,
)


def skill_col(header, items):
    parts = [Paragraph(header, skill_header_style)]
    for it in items:
        parts.append(Paragraph(f"&bull;&nbsp;&nbsp;{it}", skill_item_style))
    return parts


left = skill_col("Habilidades Técnicas", skills_tech)
right = skill_col("Habilidades Profesionales", skills_prof)

# Pad shorter column
while len(left) < len(right):
    left.append(Spacer(1, 1))
while len(right) < len(left):
    right.append(Spacer(1, 1))

skill_rows = [[l, r] for l, r in zip(left, right)]
skill_table = Table(skill_rows, colWidths=[3.5 * inch, 3.5 * inch])
skill_table.setStyle(TableStyle([
    ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ("LEFTPADDING", (0, 0), (-1, -1), 0),
    ("RIGHTPADDING", (0, 0), (-1, -1), 8),
    ("TOPPADDING", (0, 0), (-1, -1), 0),
    ("BOTTOMPADDING", (0, 0), (-1, -1), 1),
]))
story.append(skill_table)

doc.build(story)
print(f"PDF generado: {OUTPUT}")
