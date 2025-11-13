# AppPenia - Contexto del Proyecto

## Información General

**Nombre:** AppPenia
**Plataforma:** iOS 26.0+
**Framework:** SwiftUI + SwiftData
**Lenguaje:** Swift 5.0
**Xcode:** 26.0.1
**Bundle ID:** PabloSegovia.AppPenia
**Arquitectura:** MVVM con SwiftData

## Descripción del Proyecto

AppPenia es una aplicación iOS para gestionar la asistencia a reuniones semanales ("juntadas") que ocurren todos los miércoles. La aplicación permite registrar miembros, crear juntadas, y llevar un seguimiento completo de quién asiste a cada reunión, además de asignar roles específicos (sede, cocinero, lavaplatos).

## Propósito y Funcionalidades

### Gestión de Juntadas
- Registro de reuniones con fecha, notas opcionales y asignación de roles
- **Edición de juntadas existentes** - Modificar fecha, notas y roles asignados
- Roles requeridos: sede (anfitrión), cocinero y lavaplatos
- Vista de lista ordenada por fecha (más reciente primero)
- Detalle de juntada con información completa (fecha, sede con dirección, cocinero, lavaplatos, lista de asistentes)
- **Fotos de perfil mostradas** para sede, cocinero, lavaplatos y todos los asistentes
- Agregar múltiples asistentes mediante interfaz de selección múltiple (con avatares)
- Eliminar asistentes de juntadas (deslizar para eliminar)
- Eliminar juntadas completas (deslizar para eliminar)
- Botón de edición (lápiz) en barra de navegación superior izquierda

### Gestión de Miembros
- Registro de miembros con validación de nombre
- **Captura de foto de perfil** mediante cámara del dispositivo
- **Edición de perfiles de miembros** - Modificar nombre, cumpleaños, información de sede
- **Gestión de fotos** - Cambiar o eliminar fotos de perfil desde vista de perfil
- Información opcional: fecha de nacimiento (con cálculo automático de edad)
- Información de sede (si tiene) con dirección
- Vista de perfil completo con **foto de perfil grande** y estadísticas:
  - Veces que fue sede
  - Veces que cocinó
  - Veces que lavó
  - Total de asistencias
- Historial completo de asistencias por miembro (ordenado por fecha)
- Lista ordenada alfabéticamente **con avatares de perfil**
- Eliminar miembros (deslizar para eliminar)
- Botón de edición (lápiz) en barra de navegación superior derecha del perfil

### Navegación
- Navegación basada en pestañas (Juntadas / Miembros / Estadísticas)
- Navegación jerárquica con NavigationStack
- Navegación bidireccional: tocar miembro en detalle de juntada para ver perfil, tocar juntada en perfil de miembro para ver detalle
- Modal sheets para edición de datos con diseño glass consistente

## Estructura del Proyecto

```
AppPenia/
├── Models/
│   ├── Event.swift          - Entidad de juntada
│   ├── User.swift           - Entidad de miembro (con foto)
│   └── Attendance.swift     - Relación entre usuarios y juntadas
├── Views/
│   ├── MainTabView.swift    - Navegación por pestañas (3 tabs)
│   ├── EventsListView.swift - Lista de juntadas
│   ├── EventDetailView.swift - Detalle de juntada con avatares
│   ├── EditEventView.swift  - Editar juntada existente
│   ├── UsersListView.swift  - Lista de miembros con avatares
│   ├── UserProfileView.swift - Perfil de miembro con foto grande
│   ├── EditUserView.swift   - Editar perfil de miembro
│   ├── EditPhotoView.swift  - Cambiar/eliminar foto de perfil
│   └── StatisticsView.swift - Estadísticas generales
├── Components/
│   ├── GlassComponents.swift - Sistema de diseño glassmorphism
│   ├── ProfilePhotoView.swift - Componente de avatar reutilizable
│   └── CameraView.swift     - Wrapper para UIImagePickerController
├── AppPeniaApp.swift        - Punto de entrada con configuración SwiftData
└── ContentView.swift        - Wrapper a MainTabView
```

## Modelos de Datos (SwiftData)

### Event (Juntada)
```swift
@Model
class Event {
    @Attribute(.unique) var id: UUID
    var date: Date              // Fecha de la juntada
    var notes: String           // Notas opcionales
    var host: User?             // Miembro que proporciona la sede
    var cook: User?             // Miembro que cocina
    var dishwasher: User?       // Miembro que lava/limpia
    @Relationship(deleteRule: .cascade) var attendances: [Attendance]

    // Propiedades computadas
    var attendeeCount: Int
    var formattedDate: String
    var hostAddress: String
}
```

### User (Miembro)
```swift
@Model
class User {
    @Attribute(.unique) var id: UUID
    var name: String            // Nombre del miembro
    var createdAt: Date         // Fecha de registro
    var birthday: Date?         // Fecha de nacimiento opcional
    var hasSede: Bool           // Si tiene sede
    var address: String         // Dirección de la sede
    var photoData: Data?        // Foto de perfil (JPEG, compresión 0.8)
    @Relationship(deleteRule: .cascade) var attendances: [Attendance]

    // Propiedades computadas
    var attendanceCount: Int
    var age: Int?
    var formattedBirthday: String
}
```

### Attendance (Asistencia)
```swift
@Model
class Attendance {
    var user: User?
    var event: Event?
}
```

Relación muchos-a-muchos entre Users y Events. La eliminación en cascada asegura que al eliminar un miembro o juntada, se eliminan automáticamente los registros de Attendance relacionados.

## Stack Tecnológico

- **SwiftUI:** Framework declarativo para UI
- **SwiftData:** Framework moderno de persistencia (reemplaza Core Data)
- **MVVM:** Modelos, Vistas con `@Query` para datos reactivos
- **Main Actor Isolation:** Habilitado por defecto
- **Swift Approachable Concurrency:** Habilitado
- **Liquid Glass Design System:** Glassmorphism moderno con efectos de desenfoque, transparencia y animaciones

## Sistema de Diseño Liquid Glass

Componentes reutilizables en `Components/GlassComponents.swift`:

### Componentes Principales
- **GlassBackground:** Fondo animado con gradiente, círculos difusos decorativos y marca de agua del AppIcon centrada (400x400, 5% opacidad)
- **GlassCard modifier (`.glassCard()`):** Aplica efecto glass a cualquier vista con animaciones de toque
- **GlassRow:** Envoltorio de tarjeta glass preconfigurado para elementos de lista
- **GlassButtonStyle:** Estilo de botón con efecto glass y animaciones de presión
- **glassListBackground():** Combina fondo glass con ocultación de fondo de scroll
- **ProfilePhotoView:** Componente de avatar circular con 3 tamaños (small: 40px, medium: 80px, large: 150px)
- **CameraView:** Wrapper UIViewControllerRepresentable para acceso a cámara con edición habilitada

### Características de Diseño
- Efecto de desenfoque `.ultraThinMaterial` para glassmorphism intenso
- Bordes con gradiente (opacidad blanca 0.6 a 0.2)
- Efectos de sombra para profundidad (negro 15%, radio 10px)
- Animaciones spring (0.3s respuesta, 0.6 amortiguación)
- Escala (0.97x) y brillo (-5%) al presionar
- Colores del sistema adaptativos para modo claro/oscuro

### Patrón de Uso
```swift
// Aplicar a vista List completa
List { ... }
    .glassListBackground()

// Envolver elementos de lista
GlassRow {
    ContenidoView()
}

// Estilizar botones
Button("Etiqueta") { acción }
    .buttonStyle(GlassButtonStyle())
```

## Configuración de SwiftData

Configurado en `AppPeniaApp.swift`:
- Schema incluye: Event, User, Attendance
- Almacenamiento persistente (no en memoria)
- Container inyectado vía modificador `.modelContainer()`
- Vistas acceden datos vía `@Query`
- Mutaciones vía `@Environment(\.modelContext)`

## Localización

- Formato de fechas en español (es_ES)
- Configuración de locale para fechas y números

## Comandos de Compilación

**Compilar proyecto (Debug):**
```bash
xcodebuild -project AppPenia.xcodeproj -scheme AppPenia -configuration Debug build
```

**Compilar para Release:**
```bash
xcodebuild -project AppPenia.xcodeproj -scheme AppPenia -configuration Release build
```

**Limpiar carpeta de compilación:**
```bash
xcodebuild -project AppPenia.xcodeproj -scheme AppPenia clean
```

## Gestión de Fotos

### Permisos
- **NSCameraUsageDescription** configurado: "Necesitamos acceso a la cámara para tomar fotos de los miembros"

### Almacenamiento
- Fotos almacenadas como `Data?` en modelo User
- Formato JPEG con compresión 0.8
- Persistencia automática en SwiftData
- Eliminación en cascada con el usuario

### Flujo de Captura
1. Usuario toca "Tomar Foto" en AddUserView o EditPhotoView
2. CameraView presenta UIImagePickerController con fuente de cámara
3. Edición habilitada para recorte/ajuste antes de captura
4. Imagen convertida a JPEG Data y almacenada en User.photoData

### Visualización
- **Avatares pequeños (40px):** UserRow, EventDetailView (asistentes y roles), AddAttendeeView
- **Avatares medianos (80px):** Reservado para uso futuro
- **Fotos grandes (150px):** UserProfileView, EditPhotoView
- **Fallback:** Ícono `person.circle.fill` cuando no hay foto
- **Estilo:** Todos los avatares con bordes glass y sombras

## Notas Importantes

1. Todas las vistas que usan SwiftData deben importar `SwiftUI` y `SwiftData`
2. Los previews necesitan el modificador `.modelContainer(for: [Event.self, User.self, Attendance.self])`
3. El punto de entrada de la app es `MainTabView`, no `ContentView`
4. Los componentes glass requieren iOS 15+ para soporte de `.ultraThinMaterial`
5. **Acceso a cámara requiere dispositivo físico** (no disponible en simulador)
6. Fotos almacenadas en SwiftData, sin integración con biblioteca de fotos
7. Firma de código automática habilitada
8. SwiftUI Previews habilitados
9. Info.plist generado automáticamente con descripción de uso de cámara
10. Dispositivos soportados: iPhone y iPad (Universal)

## Estado Actual del Proyecto

El proyecto está completamente funcional con todas las características implementadas:
- ✅ Gestión completa de juntadas con roles
- ✅ **Edición de juntadas existentes** (fecha, notas, roles)
- ✅ Gestión completa de miembros con información detallada
- ✅ **Edición de perfiles de miembros** (nombre, cumpleaños, sede)
- ✅ **Captura y gestión de fotos de perfil** (cámara, edición, eliminación)
- ✅ **Avatares de perfil** mostrados en todas las vistas relevantes
- ✅ Sistema de asistencias con relación muchos-a-muchos
- ✅ Navegación bidireccional entre vistas
- ✅ Sistema de diseño Liquid Glass consistente con marca de agua centrada
- ✅ Estadísticas de participación por miembro
- ✅ Eliminación con cascada automática
- ✅ Validaciones de datos
- ✅ Componentes reutilizables de UI (ProfilePhotoView, CameraView)

## Próximas Mejoras Potenciales

- ✅ ~~Edición de miembros y juntadas~~ **Implementado**
- ✅ ~~Fotos de perfil~~ **Implementado**
- Estadísticas globales de la app (tab ya creado, falta implementar gráficos)
- Exportación de datos
- Notificaciones de juntadas próximas
- Filtros y búsqueda en listas
- Modo oscuro personalizado
- Compartir juntadas
- Gráficos de asistencia histórica
- Selección desde biblioteca de fotos (además de cámara)
- Zoom/recorte avanzado de fotos
