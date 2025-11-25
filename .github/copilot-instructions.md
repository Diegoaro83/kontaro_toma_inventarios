# Kontaro - Sistema de Gestión de Inventarios

**Stack**: Flutter 3.32.5 + Dart 3.8.1 | Multi-plataforma (Android, iOS, Windows, Web)  
**Cliente**: Oxígeno Zero Grados (cadena de tiendas de ropa)  
**Dispositivo objetivo**: Zebra TC15 con escáner de códigos de barras integrado

## Especificaciones Técnicas Zebra TC15

### Hardware del Dispositivo
- **Nombre comercial**: Zebra TC15 Mobile Computer
- **Propósito**: Dispositivo móvil empresarial para captura de datos y escaneo de códigos de barras
- **Factor de forma**: Handheld touch computer (computadora de mano con pantalla táctil)

### Pantalla y Dimensiones
- **Tamaño de pantalla**: 6.5 pulgadas (6.5")
- **Resolución**: 720 x 1600 píxeles (HD+)
- **Relación de aspecto**: 20:9 (pantalla alargada vertical)
- **Tipo de pantalla**: Multi-touch capacitiva
- **Densidad de píxeles**: ~270 ppi (pixels per inch)

### Procesador y Rendimiento
- **Chipset**: Qualcomm Snapdragon SM6375
- **Núcleos**: 8 cores (octa-core)
- **Frecuencia**: 2.2 GHz
- **Arquitectura**: ARM-based 64-bit

### Memoria y Almacenamiento
- **RAM**: 4 GB (4096 MB)
- **Almacenamiento interno**: 64 GB
- **Expansión**: MicroSD hasta 128 GB (slot adicional)

### Sistema Operativo
- **SO**: Android 5.0 Lollipop (API Level 21) - **Versión base de fábrica**
- **Actualizaciones**: Compatible hasta Android 11 (API 30) según modelo y región
- **Seguridad**: Google Mobile Services (GMS) certificado

### Escáner de Códigos de Barras
- **Tipo**: Escáner integrado de alto rendimiento
- **Tecnología**: Imager 2D (captura códigos 1D y 2D)
- **Alcance**: Hasta 60 cm (códigos grandes), 5-15 cm (códigos pequeños)
- **Simbología soportada**: 
  - 1D: EAN-13, UPC-A, Code 39, Code 128, Interleaved 2 of 5
  - 2D: QR Code, Data Matrix, PDF417, Aztec Code
- **Velocidad de escaneo**: <500ms por código (condiciones óptimas)
- **Iluminación LED**: Aimer rojo + flash blanco para ambientes oscuros

### Conectividad
- **Wi-Fi**: 802.11 a/b/g/n/ac (dual-band 2.4GHz y 5GHz)
- **Bluetooth**: 5.0 BLE (Low Energy)
- **Celular**: 4G LTE (opcional según modelo)
- **NFC**: Soporte para pagos y lectura de tags RFID
- **GPS**: A-GPS + GLONASS para localización

### Batería
- **Capacidad**: 4000 mAh (removible)
- **Autonomía**: 10-12 horas de uso continuo (escaneo + red)
- **Carga rápida**: USB-C con Quick Charge 3.0
- **Tiempo de carga**: ~2.5 horas (0-100%)

### Cámaras
- **Cámara trasera**: 13 MP con autofocus y flash LED
- **Cámara frontal**: 5 MP para videollamadas
- **Funciones**: Captura de documentos, OCR, escaneo de códigos

### Resistencia y Durabilidad
- **Certificación IP**: IP54 (resistente a polvo y salpicaduras)
- **Caídas**: Soporta caídas de hasta 1.2 metros sobre concreto
- **Temperatura operativa**: -10°C a 50°C
- **Temperatura de almacenamiento**: -20°C a 60°C
- **Humedad**: 5% a 95% (sin condensación)

### Emulador Android (Configuración para Desarrollo)
```
Nombre del dispositivo: Zebra TC15
Tipo: Generic Phone
Diagonal: 6.5 pulgadas
Resolución: 720 x 1600 px
Densidad: 270 dpi (hdpi)
RAM: 4096 MB
Android API: 21 (Lollipop 5.0)
ABI: x86_64 (para emulador en PC)
System Image: Google APIs Intel x86_64 Atom System Image
```

### Consideraciones para Desarrollo Flutter
1. **minSdkVersion**: 21 (requerido para TC15 con Android 5.0)
2. **Plugins requeridos**:
   - `mobile_scanner: ^5.2.3` para escáner de códigos de barras
   - Permisos en AndroidManifest: `CAMERA`, `INTERNET`, `ACCESS_FINE_LOCATION`
3. **Optimización de UI**:
   - Botones táctiles ≥48dp (recomendación Material para uso en campo)
   - Contraste alto para visibilidad en exteriores
   - Textos ≥14sp para legibilidad con guantes industriales
4. **Testing**:
   - Probar en emulador con resolución 720x1600 antes de desplegar
   - Validar escaneo con cámara del dispositivo (emulador no soporta escáner físico)
5. **Rendimiento**:
   - Optimizar imágenes (usar WebP o compresión PNG)
   - Minimizar uso de RAM (4GB compartido con SO y otros procesos)
   - Cachear datos localmente para operar sin conexión

## Arquitectura del Proyecto

### Estructura de `kontaro/lib/`
```
lib/
├── main.dart                    # Entry point - Inicializa MaterialApp con LoginScreen
├── config/app_config.dart       # Configuración central: tiendas, roles, permisos
├── theme/
│   ├── app_colors.dart         # Paleta de colores por módulo (adminBlue, inventoryGreen, etc.)
│   └── app_theme.dart          # Theme completo con estilos de botones/inputs
├── models/                      # Modelos de datos con JSON serialization
├── database/                    # ✅ Base de datos Drift ORM
│   ├── drift_database.dart     # Definición de tablas y operaciones CRUD
│   ├── drift_database.g.dart   # Código generado por build_runner
│   ├── roles_iniciales.dart    # Script de inicialización: 5 roles predefinidos
│   └── locales_iniciales.dart  # Script de inicialización: 12 tiendas/bodegas
├── services/
│   ├── drift_service.dart      # Wrapper para operaciones de BD con helpers
│   └── database_service.dart   # (Obsoleto) Migrado a Drift
├── screens/                     # Pantallas organizadas por módulo
│   ├── login/                  # ✅ Login con selección de rol/tienda
│   ├── modules/                # ✅ ModuleSelectorScreen (segunda pantalla post-login)
│   ├── users/                  # ✅ CRUD completo de usuarios
│   │   ├── creacion_usuario_screen.dart  # Crear usuarios con código aleatorio
│   │   ├── lista_usuarios_screen.dart    # Tabla/cards responsive con usuarios
│   │   └── editar_usuario_screen.dart    # Editar datos existentes
│   ├── inventory_taking/       # 🚧 Toma de inventarios
│   ├── cyclical_inventory/     # 🚧 Inventarios cíclicos
│   ├── references_query/       # 🚧 Consultas de referencias
│   ├── pos/, admin_panel/, reports/, settings/  # 📋 Pendientes
├── widgets/                     # Componentes reutilizables
│   ├── adaptive_layout.dart    # Widget responsive (móvil/desktop)
│   └── common/                 # Componentes compartidos
└── utils/
    └── responsive_helper.dart  # Breakpoints y helpers responsivos
```

### Sistema de Roles y Permisos
Definido en `lib/config/app_config.dart`:
- **5 roles**: Dirección General (ID:1), Administrador (ID:2), Gestor de Punto (ID:3), Asesor Comercial (ID:4), Auditor (ID:5)
- **Auditor**: Acceso solo a `['inventory', 'cyclical', 'references']`
- **Gestor de Punto**: Acceso a `['admin', 'pos', 'inventory', 'cyclical', 'references']`
- La función `_obtenerModulosPorRol(rolId)` en `ModuleSelectorScreen` filtra módulos según permisos

### Colores por Módulo (AppColors)
```dart
// Colores de módulos principales
adminBlue:         #2B7FFF   // Panel Administrativo
inventoryGreen:    #00BC7D   // Toma de Inventarios
posPurple:         #8200DB   // Punto de Venta
cyclicalCyan:      #06B6D4   // Inventarios Cíclicos
referencesAmber:   #F59E0B   // Consultas de Referencias

// Colores Figma (usuarios y configuración)
figmaRed:          #EA4747   // Degradado AppBar: #EA4747 → #4A2020 → #470707
figmaCyan:         #06B6D4   // Toggle switch activo/inactivo
figmaGray:         #F5F5F5   // Fondo de pantallas
```
Usado consistentemente en cards de módulos y estados (success/warning/error para stock).

## Convenciones de Código

### Nomenclatura Híbrida (Español + Inglés)
- **Clases/Widgets**: PascalCase en inglés (`LoginScreen`, `ModuleSelectorScreen`)
- **Variables/Funciones**: camelCase en **español** (`nombreUsuario`, `_obtenerModulosPorRol`)
- **Comentarios**: **Siempre en español** con emojis pedagógicos (🚀 🎨 📱 ⚠️)
- **Modelos**: Propiedades en español con `toJson()`/`fromJson()` explícitos

Ejemplo real de `login_screen.dart`:
```dart
final TextEditingController _usuarioController = TextEditingController();
String? _rolSeleccionado;  // ID del rol en español
void _iniciarSesion() { /* ... */ }
String _obtenerNombreRol(String rolId) { /* ... */ }
```

### Estilo de Comentarios (Pedagógico)
```dart
/// 📱 PANTALLA DE SELECCIÓN DE MÓDULOS
/// 
/// Pantalla que muestra después del login con:
/// - Hora en la parte superior
/// - Información del perfil activo y usuario
/// - Lista de módulos disponibles según el rol

// 🔍 Buscar usuario por cédula (PK - Primary Key)
Future<Usuario?> obtenerUsuarioPorCedula(String cedula) { /* ... */ }

// ✏️ Actualizar solo los campos que cambiaron (sin reemplazar objeto completo)
Future<int> actualizarUsuarioParcial(String cedula, Map<String, dynamic> cambios) { /* ... */ }

// 🎨 Construir card de sección con ícono y título (reutilizable en formularios)
Widget _buildSeccionCard({
  required IconData icono,  // Ícono izquierdo del card
  required Color colorIcono,  // Color del ícono y borde focus
  required String titulo,  // Texto del header
  required List<Widget> children,  // Contenido del card
}) { /* ... */ }
```
**REGLA OBLIGATORIA**: TODOS los métodos, funciones y widgets deben tener comentario explicando:
1. **Qué hace** (verbo de acción)
2. **Para qué sirve** (propósito o contexto de uso)
3. **Parámetros importantes** (si aplica, inline después del parámetro)

Usar emojis pedagógicos: 🚀 inicio, 🎨 UI, 📱 responsive, ⚠️ advertencia, ✅ éxito, 🔍 búsqueda, ✏️ edición, 🗑️ eliminación, 🔐 seguridad

### Navegación
- **Actual**: `Navigator.push()` manual entre `LoginScreen` → `ModuleSelectorScreen`
- **Configurado pero no usado**: `go_router: ^14.6.2` en `pubspec.yaml`
- **Próximo paso**: Migrar a GoRouter para deep linking

## Comandos de Desarrollo

### Iniciar Proyecto
```powershell
cd kontaro
flutter pub get                 # Instalar dependencias
flutter run -d windows          # Ejecutar en Windows
flutter run -d android          # Ejecutar en Android (requiere emulador)
flutter run                     # Auto-detecta dispositivo disponible
```

### Hot Reload
- `r` = Hot reload (preserva estado)
- `R` = Hot restart (reinicia app)
- `q` = Cerrar aplicación

### Debugging
- `flutter doctor` = Verificar configuración del entorno
- `flutter clean` = Limpiar cache si hay errores de build
- Ver logs en VSCode: Panel "DEBUG CONSOLE" cuando app corre

### Android Build Config
- `minSdk = 21` (Android 5.0) requerido para `mobile_scanner`
- `ndkVersion = "27.0.12077973"` fijado para evitar warnings de plugins
- Permisos en `AndroidManifest.xml`: CAMERA, INTERNET, STORAGE

## Dependencias Clave

### Base de Datos (Drift ORM)
- `drift: ^2.18.0` - ORM principal para SQLite con type-safety
- `drift_flutter: ^0.1.0` - Integración Flutter para Drift
- `drift_dev: ^2.18.0` - Generador de código (dev dependency)
- `build_runner: ^2.4.0` - Ejecuta generadores de código
- `path: ^1.9.0` - Manejo de rutas para ubicar archivo .db

**Comando de generación**: `dart run build_runner build --delete-conflicting-outputs`

### Core Features
- `mobile_scanner: ^5.2.3` - Escaneo de códigos de barras (TC15)
- `excel: ^4.0.6` + `file_picker: ^8.1.4` - Importar/exportar inventarios

### Estado y Navegación
- `provider: ^6.1.2` - Gestión de estado (configurado pero no implementado)
- `go_router: ^14.6.2` - Navegación declarativa (pendiente migración)

### UI/UX
- `flutter_svg: ^2.0.10+1` - Iconos vectoriales
- `shimmer: ^3.0.0` - Loading states
- `cached_network_image: ^3.4.1` - Optimización de imágenes
- `responsive_builder: ^0.7.0` - Helpers para diseño responsive
- `flutter_screenutil: ^5.9.3` - Escalado de UI por tamaño de pantalla

## Flujo de Usuario Actual

### Login → Selector de Módulos → CRUD Usuarios
1. **LoginScreen** (`lib/screens/login/login_screen.dart`):
   - Usuario ingresa credenciales (sin validación real por ahora)
   - Selecciona rol de dropdown (`Rol.rolesDefault()`)
   - Al presionar "INICIAR SESIÓN": `Navigator.push()` a `ModuleSelectorScreen`
   
2. **ModuleSelectorScreen** (`lib/screens/modules/module_selector_screen.dart`):
   - Muestra hora actual + información de perfil
   - Lista módulos filtrados por `_obtenerModulosPorRol(rolId)`
   - **Dirección General (rol '1')** tiene acceso a:
     - 🆕 Creación de Usuarios (rojo #EA4747)
     - 👥 Lista de Usuarios (rojo #EA4747)
     - Todos los demás módulos

3. **CRUD de Usuarios** (solo Dirección General):
   - **Crear**: Formulario completo con código aleatorio de 4 dígitos
   - **Leer**: Tabla responsive (desktop) o cards (móvil)
   - **Actualizar**: Formulario pre-llenado, contraseña opcional
   - **Eliminar**: Confirmación con diálogo de seguridad

### Diseño Visual (Figma)
- **Login Desktop**: Frame 1:5 - Implementado pixel-perfect con gradientes, sombras, medidas exactas
- **Login Móvil**: Frame 1:104 - Versión para TC15 con barra de estado Android
- **Post-login**: No existe en Figma, diseñado basado en mockup textual del usuario

## Integración Figma

- **Token personal**: Almacenado localmente (usuario tiene acceso)
- **File Key**: `xhlFTjms5cZCHcSYnHGoDe`
- **JSON local**: `kontaro/figma_design.json` con especificaciones completas
- **Método**: Usar API de Figma para extraer colores, dimensiones, gradientes exactos

Ejemplo de especificación aplicada:
```dart
// De Figma JSON → Código Flutter
cornerRadius: 12.0              // borderRadius: BorderRadius.circular(12)
strokeWeight: 1.1077599525      // border: Border.all(width: 1.1)
gradientStops: [0.0, 0.529, 1.0] // LinearGradient con 3 stops exactos
```

## Patrones de Estado

### StatefulWidget vs StatelessWidget
- **StatefulWidget**: Cuando hay interacción con formularios (`LoginScreen` con controladores de texto)
- **StatelessWidget**: Para pantallas solo de lectura o con datos pasados por constructor (`ModuleSelectorScreen`)

### Manejo de Listas
```dart
// Patrón usado en ModuleSelectorScreen
final modulos = _obtenerModulosPorRol(rolId);  // Filtrado en build()
...modulos.map((modulo) => _buildModuloItem(context, modulo))  // Spread operator para lista
```

## Base de Datos (Drift ORM)

### Arquitectura de 3 Capas
```
Pantallas (UI)
    ↓ llama a
DriftService (Wrapper con helpers)
    ↓ llama a
DriftDatabase (Definición de tablas y operaciones)
    ↓ usa
kontaro_drift.db (Archivo SQLite físico)
```

### Tablas Implementadas
1. **Roles** (15 columnas):
   - `id` (String PK): '1' a '5' para roles predefinidos
   - `nombre`, `descripcion`: Textos descriptivos
   - `permisos` (String): CSV de permisos ('inventarios,usuarios,reportes')
   - Flags booleanos: `puedeCrearUsuarios`, `puedeEditarInventarios`, etc.
   - `activo` (bool): Para deshabilitar roles sin eliminarlos

2. **Locales** (9 columnas):
   - `id` (String PK): 'LC_01', 'BD_01', etc.
   - `tipo` (String): 'tienda' o 'bodega'
   - `nombre`, `direccion`, `telefono`, `ciudad`: Datos de contacto
   - `activo`, `fechaCreacion`, `fechaModificacion`

3. **Usuarios** (11 columnas):
   - `cedula` (String PK): Identificación única, no editable
   - `nombresApellidos`, `nombreUsuario`, `telefono`
   - `contrasena` (String): Se debe hashear antes de guardar
   - `rolId` (String FK → Roles.id): Relación con tabla Roles
   - `localAsignado` (String FK → Locales.id): Tienda/bodega del usuario
   - `codigo` (String unique): 4 dígitos aleatorios (1000-9999)
   - `activo` (bool): Para deshabilitar sin eliminar
   - `fechaCreacion`, `fechaModificacion`

4. **Sesiones** (11 columnas) - **NUEVA**:
   - `id` (String PK): 'sesion-001', 'sesion-002', etc. (formato incremental)
   - `nombreLocal` (String): Nombre del local (ej: "Restrepo", "Vistao")
   - `localId` (String FK → Locales.id): Referencia al local donde se realiza el inventario
   - `estado` (String): 'en_progreso', 'finalizada', 'cancelada'
   - `usuarioCreador` (String FK → Usuarios.cedula): Usuario que creó la sesión
   - `totalReferencias` (int): Total de productos/referencias a contar en la sesión
   - `referenciasEscaneadas` (int default 0): Contador de productos ya escaneados
   - `dispositivosConectados` (int default 1): Número de TC15 activos en esta sesión
   - `fechaCreacion` (DateTime): Timestamp de inicio de sesión
   - `fechaFinalizacion` (DateTime nullable): Timestamp cuando se finaliza
   - `observaciones` (String nullable): Notas adicionales sobre la sesión
   
   **Propósito**: Gestionar sesiones de conteo de inventario donde múltiples dispositivos TC15 pueden colaborar en una misma sesión, escaneando códigos de barras en paralelo. El sistema registra el progreso en tiempo real y permite ver qué sesiones están activas.
   
   **Workflow multi-dispositivo**:
   1. Usuario A crea sesión en TC15 #1 → `dispositivosConectados = 1`
   2. Usuario B se une desde TC15 #2 → `dispositivosConectados = 2`
   3. Ambos escanean códigos → `referenciasEscaneadas` incrementa en tiempo real
   4. Al llegar a `totalReferencias`, sesión se marca como 'finalizada'

### Operaciones CRUD Principales

#### Usuarios
```dart
// ✅ Crear usuario con todos los campos requeridos
Future<int> crearUsuario({
  required String cedula,  // PK, no se puede cambiar después
  required String nombresApellidos,
  required String nombreUsuario,
  String? telefono,  // Opcional
  required String contrasena,  // Debe hashearse con bcrypt/similar
  required String rolId,  // FK a Roles ('1' a '5')
  required String localAsignado,  // FK a Locales ('LC_01', etc.)
  required String codigo,  // 4 dígitos generados aleatoriamente
  required bool activo,  // true por defecto
})

// 🔍 Obtener todos los usuarios ordenados por nombre
Future<List<UsuarioData>> obtenerUsuarios()

// ✏️ Actualizar campos específicos sin reemplazar todo el objeto
// Solo se actualizan los campos presentes en el mapa 'cambios'
Future<int> actualizarUsuarioParcial(
  String cedula,  // PK del usuario a actualizar
  Map<String, dynamic> cambios,  // {'nombreUsuario': 'nuevo', 'telefono': '123'}
)

// 🗑️ Eliminar usuario por cédula (hard delete, no soft delete)
Future<int> eliminarUsuario(String cedula)
```

#### Roles y Locales
```dart
// 📋 Obtener roles activos para dropdowns
Future<List<RoleData>> obtenerRolesActivos()

// 🏪 Obtener locales activos para dropdowns
Future<List<LocaleData>> obtenerLocalesActivos()
```

#### Sesiones de Inventario
```dart
// ✅ Crear nueva sesión de inventario
Future<int> crearSesion({
  required String id,  // sesion-001, sesion-002, etc.
  required String nombreLocal,  // "Restrepo", "Vistao", etc.
  required String localId,  // FK a Locales ('LC_01', etc.)
  required String usuarioCreador,  // Cédula del usuario
  required int totalReferencias,  // Total de productos a contar
  String? observaciones,  // Notas adicionales (opcional)
})

// 🔍 Obtener todas las sesiones ordenadas por fecha (más recientes primero)
Future<List<SesioneData>> obtenerSesiones()

// 🔍 Obtener sesiones por estado ('en_progreso', 'finalizada', 'cancelada')
Future<List<SesioneData>> obtenerSesionesPorEstado(String estado)

// 🔍 Obtener sesiones por local
Future<List<SesioneData>> obtenerSesionesPorLocal(String localId)

// ✏️ Actualizar progreso de sesión (cuando se escanea un código)
Future<int> actualizarProgresoSesion(String id, int referenciasEscaneadas)

// ➕ Incrementar dispositivos conectados (cuando otro TC15 se conecta)
Future<int> incrementarDispositivosConectados(String id)

// ➖ Decrementar dispositivos conectados (cuando un TC15 se desconecta)
Future<int> decrementarDispositivosConectados(String id)

// ✅ Finalizar sesión (marcar como finalizada con fecha)
Future<int> finalizarSesion(String id)

// ❌ Cancelar sesión
Future<int> cancelarSesion(String id)

// 📊 Contar sesiones activas (en progreso)
Future<int> contarSesionesActivas()

// 👀 Stream de sesiones (actualización en tiempo real)
Stream<List<SesioneData>> watchSesiones()
```

### Inicialización Automática
Al primer arranque, se ejecutan scripts de datos iniciales:
- **5 roles** definidos en `roles_iniciales.dart`
- **12 locales** (8 tiendas + 4 bodegas) en `locales_iniciales.dart`

### Ubicación del Archivo de BD
```dart
// Windows: C:\Users\[USUARIO]\OneDrive\Documentos\kontaro_drift.db
// Android: /data/data/com.kontaro.app/databases/kontaro_drift.db
// iOS: ~/Library/Application Support/kontaro_drift.db
```

Para resetear BD durante desarrollo:
```powershell
del "C:\Users\LENOVO\OneDrive\Documentos\kontaro_drift.db"
```

## Diseño Responsive

### Breakpoints
```dart
mobile:   < 600px   // Teléfonos
tablet:   600-900px // Tablets
desktop:  ≥ 900px   // PC/laptops
```

### Patrón de Implementación
```dart
// ✅ Detectar tamaño de pantalla
final screenWidth = MediaQuery.of(context).size.width;
final isMobile = screenWidth < 900;

// ✅ Layout condicional
if (isMobile) {
  // Columna única, botones apilados
  Column(children: [campo1, campo2])
} else {
  // 2 columnas lado a lado
  Row(children: [Expanded(child: campo1), SizedBox(width: 16), Expanded(child: campo2)])
}
```

### Widgets Responsive Creados
- `AdaptiveLayout`: Cambia entre `mobileBody` y `desktopBody` automáticamente
- `ResponsiveHelper`: Helpers para breakpoints y sizing

## Patrones de Diseño Figma

### Degradado Rojo (AppBar de Usuarios)
```dart
// ✅ Aplicar en AppBar con flexibleSpace
AppBar(
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFEA4747), Color(0xFF4A2020), Color(0xFF470707)],
        stops: [0.0, 0.529, 1.0],  // Posiciones exactas de Figma
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  ),
)
```

### Cards con Secciones (Formularios)
```dart
// ✅ Estructura de 3 secciones con íconos
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,  // Fondo blanco del card
    borderRadius: BorderRadius.circular(12),  // Bordes redondeados
    boxShadow: [  // Sombra sutil
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    children: [
      // Header con ícono
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEA4747).withOpacity(0.1),  // Fondo de ícono
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person_outline, color: Color(0xFFEA4747)),
          ),
          SizedBox(width: 12),
          Text('Título de Sección', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      // Contenido de la sección
      ...children,
    ],
  ),
)
```

### Toggle Switch Cyan
```dart
// ✅ Switch con colores Figma
Switch(
  value: _activoCheckbox,
  onChanged: (v) => setState(() => _activoCheckbox = v),
  activeColor: const Color(0xFF06B6D4),  // Cyan cuando activo
  activeTrackColor: const Color(0xFF06B6D4).withOpacity(0.5),  // Track transparente
)
```

## Para Nuevos Agentes AI

### ⚠️ REGLA CRÍTICA: NO EJECUTAR CAMBIOS SIN APROBACIÓN
**ANTES de modificar CUALQUIER archivo de código:**
1. **DETENTE** y explica qué cambios propones
2. **DESCRIBE** exactamente qué archivos se modificarán y por qué
3. **ESPERA** la aprobación explícita del usuario
4. **SOLO ENTONCES** ejecuta los cambios

**Excepciones** (puedes hacer SIN preguntar):
- Leer archivos para entender el código
- Buscar información (grep, semantic_search)
- Ejecutar comandos de consulta (flutter doctor, git status)
- Responder preguntas teóricas

### Enfoque Pedagógico
- Usuario está aprendiendo programación desde cero
- Explicar cada decisión técnica en español coloquial
- Evitar jerga sin contexto (ej: "state lifting" → "pasar datos entre pantallas")
- Validar cada cambio corriendo la app, no solo teoría
- **OBLIGATORIO**: Agregar comentarios explicativos a TODO el código generado

### Al Crear Nuevas Pantallas
1. Verificar colores en `AppColors` antes de hardcodear
2. Consultar `AppConfig` para datos de tiendas/roles
3. Usar estructura `_buildNombreWidget()` para componentes privados
4. **Agregar comentario en cada método/función** explicando qué hace y por qué
5. Usar layout responsive (if/else con isMobile)
6. Probar en Windows primero (más rápido), luego Android

### Al Trabajar con Drift
1. **Siempre** definir tablas en `drift_database.dart`
2. Ejecutar `dart run build_runner build --delete-conflicting-outputs` después de cambios
3. Envolver operaciones en `DriftService` con métodos helpers
4. Usar tipos generados: `UsuarioData`, `RoleData`, `LocaleData`
5. Manejar errores con try/catch y mostrar SnackBars informativos

### Estructura de Comentarios Requerida
```dart
/// 📱 TÍTULO DE PANTALLA/WIDGET EN MAYÚSCULAS
/// 
/// Descripción de qué hace y cuándo se usa.
/// - Punto importante 1
/// - Punto importante 2

// 🎨 Construir [componente] con [características]
Widget _buildComponente({
  required String parametro1,  // Para qué sirve parametro1
  Color? parametro2,  // Para qué sirve parametro2 (opcional)
}) {
  // Lógica explicada paso a paso si es compleja
  return Container(/* ... */);
}

// 🔍 Buscar [entidad] por [criterio]
Future<List<Entidad>> buscarPorCriterio(String criterio) async {
  // Explicar por qué se hace así
  return await db.select(tabla).get();
}
```

### Debugging Común
- **Error NDK**: Versión fijada en `android/app/build.gradle.kts`
- **Errores de permisos Android**: Verificar `AndroidManifest.xml`
- **Hot reload no funciona**: Usar `R` para restart completo
- **Imports no usados**: El linter los marca, remover para pasar análisis
- **Drift no genera archivos**: Ejecutar build_runner manualmente
- **BD corrupta**: Eliminar archivo .db y reiniciar app para recrearla

---

## Control de Versiones (Git)

### Configuración Actual
- **Repositorio**: Inicializado en `kontaro/`
- **Usuario Git**: Diego - Kontaro Team
- **Email**: diegoaro83@gmail.com
- **Branch principal**: `master`
- **Primer commit**: `777cd1e` - Sistema Kontaro v1.0

### Comandos Git Esenciales

#### Ver Estado y Historial
```powershell
# Ver archivos modificados
git status

# Ver historial de versiones
git log --oneline --graph --decorate

# Ver cambios en un archivo específico
git diff ruta/archivo.dart

# Ver qué cambió en un commit específico
git show 777cd1e
```

#### Crear Versiones (Commits)
```powershell
# 1. Agregar archivos modificados al staging
git add .                        # Todos los archivos
git add lib/screens/login/       # Solo una carpeta
git add archivo.dart             # Solo un archivo

# 2. Crear commit con mensaje descriptivo
git commit -m "feat: descripción del cambio"

# Ejemplos de mensajes:
git commit -m "feat: agregar módulo de inventarios cíclicos"
git commit -m "fix: corregir error en login de Auditor"
git commit -m "style: mejorar colores según Figma"
git commit -m "refactor: optimizar queries de Drift"
```

#### Prefijos de Commits Recomendados
- `feat:` - Nueva funcionalidad
- `fix:` - Corrección de errores
- `style:` - Cambios visuales (colores, diseño)
- `refactor:` - Reorganización de código sin cambiar funcionalidad
- `docs:` - Actualización de documentación
- `test:` - Agregar o modificar tests
- `chore:` - Tareas de mantenimiento (dependencias, configs)

#### Navegación entre Versiones
```powershell
# Volver a una versión anterior (SIN perder cambios actuales)
git checkout 777cd1e              # Ver código de ese commit
git checkout master               # Volver a la última versión

# Crear rama para experimentar (sin afectar master)
git branch experimento
git checkout experimento          # Cambiar a la rama

# Volver a master
git checkout master
```

#### Archivos Ignorados (.gitignore)
Archivos que **NO** se versionan automáticamente:
- `build/` - Carpetas de compilación
- `.dart_tool/` - Herramientas de Dart
- `*.g.dart` - Archivos generados por build_runner
- `*.db` - Bases de datos locales con datos de prueba
- `windows/flutter/ephemeral/` - Archivos temporales de Windows

### Flujo de Trabajo Recomendado

**Antes de iniciar cambios importantes:**
```powershell
git status                        # Verificar que no hay cambios pendientes
```

**Después de completar una funcionalidad:**
```powershell
git add .
git commit -m "feat: descripción del cambio"
git log --oneline                 # Confirmar que el commit se creó
```

**Si algo sale mal y quieres deshacer cambios:**
```powershell
git status                        # Ver qué archivos cambiaron
git checkout -- archivo.dart      # Deshacer cambios en un archivo
git reset --hard HEAD             # ⚠️ DESHACER TODO (sin recuperación)
```

### Buenas Prácticas
1. **Commits frecuentes**: Crear versión después de cada funcionalidad completa
2. **Mensajes claros**: Explicar QUÉ se cambió y POR QUÉ
3. **Probar antes de commit**: Ejecutar `flutter run` y verificar que funciona
4. **No versionar bases de datos**: `.db` está en `.gitignore`
5. **Revisar antes de commit**: Usar `git status` y `git diff`

---

**Estado actual**: 
- ✅ Login + Selector de Módulos
- ✅ CRUD Usuarios Completo (Crear, Listar, Editar, Eliminar)
- ✅ Base de datos Drift con 7 tablas (Roles, Locales, Usuarios, Productos, **Sesiones**, Inventarios, DetallesInventario)
- ✅ Pantalla de Módulos del Auditor con diseño Figma
- ✅ **Pantalla de Sesiones de Inventario** con datos mock (nueva)
- ✅ Sistema de Sesiones con multi-dispositivo implementado (DB + Services)
- ✅ Navegación completa: Login → Módulos → Toma Inventario → Sesiones
- ✅ Diseño responsive móvil/desktop
- ✅ Colores Figma aplicados (#1A202C fondo, íconos saturados)
- ✅ Control de versiones Git configurado
- 🔜 Formulario crear nueva sesión (siguiente paso)
- 🔜 Pantalla de escaneo con cámara (siguiente paso)
- 🚧 Inventarios Cíclicos (placeholder)
- 🚧 Consultas de Referencias (placeholder)

**Última actualización**: 22 de noviembre de 2025
**Última versión Git**: `777cd1e` - Sistema Kontaro v1.0
**Última versión Git**: `90eb536
**En desarrollo**: Sesiones de Inventario (funcional con mock data)
