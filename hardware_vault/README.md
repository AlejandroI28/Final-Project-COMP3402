# 🖥️ Hardware Vault

Una aplicación móvil Flutter de demostración para explorar hardware de computadoras: CPUs, GPUs, noticias y gestión de builds personales.

---

## 📱 Secciones

| Sección | Tab | Descripción |
|---------|-----|-------------|
| **Catálogo** | Izquierda | Lista de CPUs (Intel, AMD) y GPUs (Nvidia, AMD, Intel) con búsqueda y filtros por marca |
| **Noticias** | Centro | Artículos recientes sobre hardware, eventos y lanzamientos |
| **Mi Equipo** | Derecha | Guarda y gestiona tus configuraciones de PC personales |

---

## 🚀 Setup

### Requisitos
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code con Flutter plugin

### Instalación

```bash
# 1. Clonar o descomprimir el proyecto
cd hardware_vault

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en dispositivo/emulador
flutter run

# 4. Build APK para Android
flutter build apk --release

# 5. Build para iOS (requiere Mac)
flutter build ipa
```

---

## 📦 Dependencias

| Paquete | Uso |
|---------|-----|
| `provider` | Gestión de estado |
| `google_fonts` | Tipografía (Space Grotesk) |
| `shared_preferences` | Persistencia local de builds |
| `timeago` | Fechas relativas en noticias |
| `shimmer` | Efectos de carga |

---

## 🎨 Diseño

- **Tema**: Dark mode exclusivo
- **Color principal**: Verde `#00C853`
- **Colores de marca**: Intel Azul, AMD Rojo, Nvidia Verde
- **Tipografía**: Space Grotesk (Google Fonts)

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                    # Entrada de la app + navegación
├── theme/
│   └── app_theme.dart           # Paleta de colores y estilos
├── models/
│   └── models.dart              # CPU, GPU, NewsArticle, PCBuild
├── data/
│   └── mock_data.dart           # Datos demo (13 CPUs, 18 GPUs, 8 noticias)
├── providers/
│   └── app_state.dart           # Estado global (Provider)
├── widgets/
│   └── shared_widgets.dart      # Componentes reutilizables
└── screens/
    ├── catalog_screen.dart      # Tab Catálogo
    ├── news_screen.dart         # Tab Noticias
    ├── my_equipment_screen.dart # Tab Mi Equipo
    └── part_detail_screen.dart  # Vista detalle CPU/GPU
```

---

## 💾 Datos Demo incluidos

### CPUs (13 modelos)
- **Intel**: Core Ultra 9/7/5 285K/265K/245K (Arrow Lake), i9/i7/i5 14900K/14700K/14600K
- **AMD**: Ryzen 9/7/5 9950X/9900X/9700X/9600X (Granite Ridge), Ryzen 9/9/7 7950X3D/7900X3D/7800X3D

### GPUs (18 modelos)
- **Nvidia**: RTX 5090/5080/5070Ti/5070 (Blackwell), RTX 4090/4080S/4070TiS/4070S/4060Ti (Ada)
- **AMD**: RX 9070XT/9070 (RDNA 4), RX 7900XTX/7900GRE/7800XT/7700XT (RDNA 3)
- **Intel**: Arc B580/B570 (Battlemage), Arc A770

### Noticias (8 artículos)
- Fuentes: TechPowerUp, AnandTech, Tom's Hardware, GamersNexus, Digital Foundry, etc.
- Categorías: GPU, CPU, Memory, Event

---

## ✨ Features

- 🔍 **Búsqueda en tiempo real** por nombre/serie
- 🏷️ **Filtros por marca** (Intel / AMD / Nvidia)
- 📊 **Score bars** con benchmarks comparativos
- 💰 **Precios MSRP** actualizados
- 🖥️ **Builds guardados** con SharedPreferences (persiste entre sesiones)
- 📰 **Noticias con timestamps** relativos en español
- 🎨 **Paleta verde oscura** con acentos de marca por fabricante
