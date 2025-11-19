# AppPenia 🍻

**Aplicación iOS para gestión de juntadas semanales con seguimiento de asistencias y gastos compartidos**

---

## 📱 Descripción

AppPenia es una aplicación nativa de iOS diseñada para gestionar reuniones semanales recurrentes ("juntadas") entre un grupo de amigos. La aplicación permite registrar asistencias, roles (sede, cocina, lavado), gestionar gastos compartidos con división automática de deudas, y visualizar estadísticas detalladas del grupo.

## ✨ Características Principales

### 🎉 Gestión de Juntadas
- Registro de eventos con fecha, notas y fotos
- Asignación de roles requeridos:
  - **Sede**: Miembro que provee el lugar (debe tener sede registrada)
  - **Cocina**: Miembro encargado de cocinar
  - **Lavado**: Miembro encargado de limpiar
- Lista de asistentes con gestión visual (fotos de perfil)
- Visualización de mapa con ubicación de la sede
- Historial completo de juntadas ordenado cronológicamente

### 👥 Gestión de Miembros
- Perfiles completos con:
  - Foto de perfil (captura con cámara)
  - Nombre y fecha de nacimiento (con cálculo automático de edad)
  - Información de sede (dirección con visualización en mapa)
  - Estadísticas individuales (veces que hospedó, cocinó, lavó)
  - Balance financiero completo
- Historial de asistencias por miembro
- Contador total de asistencias

### 💰 Sistema de Gastos Compartidos
- Registro de gastos por juntada con soporte multi-pagador
- División automática del gasto entre asistentes
- **Algoritmo de optimización de deudas** (greedy algorithm):
  - Minimiza el número de transacciones necesarias
  - Calcula balance neto por usuario
  - Simplifica pagos entre credores y deudores
- Vista detallada de gastos:
  - Quién puso dinero (verde)
  - Quién le debe a quién (cyan)
  - Balance por persona
- Balance financiero por miembro:
  - Total contribuido
  - Total adeudado
  - Monto que le deben
  - Balance neto con código de colores

### 📊 Estadísticas y Gráficos
Cuatro gráficos interactivos con SwiftUI Charts:
1. **Asistencias por miembro** (gradiente azul-púrpura)
2. **Estadísticas de sede** - Quién hospedó más veces (gradiente naranja-rosa)
3. **Estadísticas de cocina** - Frecuencia de cocina (gradiente verde-menta)
4. **Estadísticas de lavado** - Frecuencia de lavado (gradiente cyan-azul)

### 🗺️ Integración de Mapas
- Geocodificación automática de direcciones con MKLocalSearch
- Visualización de ubicación de sedes con:
  - Marcadores personalizados (icono de casa)
  - Elevación realista del terreno
  - Zoom de 500 metros
- Mapas visibles en:
  - Detalle de juntada (ubicación de la sede)
  - Perfil de miembro (su sede)
  - Vista previa en vivo al crear/editar miembros

### 📸 Gestión de Fotos
- Captura de fotos con cámara integrada
- Edición de fotos antes de guardar
- Almacenamiento en SwiftData (JPEG con compresión 0.8)
- Visualización de avatares en múltiples tamaños:
  - **Small**: 40px (listas, asistentes, roles)
  - **Medium**: 80px (reservado)
  - **Large**: 150px (perfiles)
- Soporte para fotos de:
  - Miembros (perfiles con foto)
  - Juntadas (fotos de eventos con thumbnails 60x60 en lista)

### 🎨 Diseño Liquid Glass
- Sistema de diseño glassmorphism completo:
  - Efectos de desenfoque `.ultraThinMaterial`
  - Bordes con gradientes de opacidad
  - Sombras para profundidad
  - Animaciones suaves con spring physics
  - Fondos animados con degradados y círculos blur
  - Marca de agua con AppIcon (400x400, 5% opacidad)
- Componentes reutilizables:
  - `GlassCard`, `GlassRow`, `GlassButtonStyle`
  - `GlassBackground` con animación
- Adaptación automática a modo claro/oscuro
- Opacidad de fondos de listas al 30% para mayor transparencia

## 🛠️ Stack Tecnológico

### Frameworks y Tecnologías
- **SwiftUI**: Framework declarativo de UI
- **SwiftData**: Persistencia moderna (schema-driven)
- **MapKit**: Integración de mapas y geocodificación
- **Charts**: Framework de gráficos (iOS 16+)
- **UIKit**: UIImagePickerController para cámara

### Arquitectura
- **Patrón MVVM**: Models, Views con `@Query` reactivo
- **Main Actor Isolation**: Configurado por defecto
- **Swift Concurrency**: async/await, actores
- **Cascade Deletion**: Relaciones con eliminación en cascada

### Requisitos
- **Xcode**: 26.0.1
- **iOS**: 26.0+
- **Swift**: 5.0
- **Dispositivos**: iPhone y iPad (Universal)

### Localización
- **Fechas**: Español (es_ES)
- **Moneda**: Peso Argentino (es_AR)

## 📂 Estructura del Proyecto

```
AppPenia/
├── Models/
│   ├── Event.swift          # Entidad de juntadas
│   ├── User.swift           # Entidad de miembros
│   ├── Attendance.swift     # Relación muchos-a-muchos
│   ├── Expense.swift        # Gastos con cálculo de deudas
│   └── Payment.swift        # Registros de pagos
├── Views/
│   ├── MainTabView.swift    # Navegación principal (4 tabs)
│   ├── EventsListView.swift # Lista de juntadas
│   ├── EventDetailView.swift # Detalle de juntada
│   ├── EditEventView.swift  # Edición de juntada
│   ├── UsersListView.swift  # Lista de miembros
│   ├── UserProfileView.swift # Perfil de miembro
│   ├── EditUserView.swift   # Edición de miembro
│   ├── EditPhotoView.swift  # Gestión de fotos
│   ├── StatisticsView.swift # Gráficos y estadísticas
│   ├── ExpensesTabView.swift # Lista de gastos
│   ├── AddExpenseView.swift # Agregar gasto
│   └── ExpenseDetailView.swift # Detalle de gasto
├── Components/
│   ├── GlassComponents.swift # Sistema de diseño glass
│   ├── ProfilePhotoView.swift # Avatares reutilizables
│   ├── CameraView.swift     # Wrapper de cámara
│   └── SedeMapView.swift    # Componente de mapa
└── AppPeniaApp.swift        # Entrada de la app
```

## 🔧 Características Técnicas Destacadas

### Modelos de Datos (SwiftData)
- **Event**: Juntadas con relaciones a User (roles), Attendance, Expense
- **User**: Miembros con foto, cumpleaños, sede, relaciones a Attendance
- **Attendance**: Join table con cascade deletion
- **Expense**: Usa `Decimal` para precisión financiera
- **Payment**: Múltiples pagadores por gasto

### Algoritmo de Optimización de Deudas
```
1. Calcular balance neto por usuario (pagado - adeudado)
2. Separar en credores (+) y deudores (-)
3. Ordenar por monto absoluto descendente
4. Emparejar mayor credo con mayor deudor
5. Transferir mínimo de ambos montos
6. Actualizar balances y repetir
Resultado: Mínimo número de transacciones
```

### Componentes Reutilizables
- **ProfilePhotoView**: 3 tamaños configurables con fallback
- **SedeMapView**: Geocodificación asíncrona con estados (loading, error, success)
- **GlassBackground**: Fondo animado con degradados y blur
- **CameraView**: UIViewControllerRepresentable para captura de fotos

### Relaciones de Datos
- Muchos-a-muchos: User ↔ Event (via Attendance)
- Uno-a-uno: Event → Expense (opcional)
- Uno-a-muchos: Expense → Payment
- Eliminación en cascada automática

---

# AppPenia 🍻

**iOS app for managing weekly gatherings with attendance tracking and shared expenses**

---

## 📱 Description

AppPenia is a native iOS application designed to manage recurring weekly meetings ("juntadas") among a group of friends. The app allows you to register attendances, roles (host, cook, dishwasher), manage shared expenses with automatic debt simplification, and view detailed group statistics.

## ✨ Main Features

### 🎉 Gatherings Management
- Event registration with date, notes, and photos
- Required role assignments:
  - **Host**: Member who provides the venue (must have a registered headquarters)
  - **Cook**: Member in charge of cooking
  - **Dishwasher**: Member in charge of cleaning
- Attendee list with visual management (profile photos)
- Map visualization with host location
- Complete chronologically ordered gathering history

### 👥 Members Management
- Complete profiles with:
  - Profile photo (camera capture)
  - Name and birthdate (with automatic age calculation)
  - Headquarters information (address with map visualization)
  - Individual statistics (times hosted, cooked, cleaned)
  - Complete financial balance
- Attendance history per member
- Total attendance counter

### 💰 Shared Expenses System
- Expense registration per gathering with multi-payer support
- Automatic expense division among attendees
- **Debt optimization algorithm** (greedy algorithm):
  - Minimizes number of required transactions
  - Calculates net balance per user
  - Simplifies payments between creditors and debtors
- Detailed expense view:
  - Who paid (green)
  - Who owes whom (cyan)
  - Balance per person
- Financial balance per member:
  - Total contributed
  - Total owed
  - Amount owed to user
  - Net balance with color coding

### 📊 Statistics and Charts
Four interactive charts with SwiftUI Charts:
1. **Attendance by member** (blue-purple gradient)
2. **Host statistics** - Who hosted most often (orange-pink gradient)
3. **Cook statistics** - Cooking frequency (green-mint gradient)
4. **Dishwasher statistics** - Cleaning frequency (cyan-blue gradient)

### 🗺️ Map Integration
- Automatic address geocoding with MKLocalSearch
- Headquarters location visualization with:
  - Custom markers (house icon)
  - Realistic terrain elevation
  - 500-meter zoom
- Maps visible in:
  - Gathering detail (host location)
  - Member profile (their headquarters)
  - Live preview when creating/editing members

### 📸 Photo Management
- Integrated camera photo capture
- Photo editing before saving
- SwiftData storage (JPEG with 0.8 compression)
- Avatar display in multiple sizes:
  - **Small**: 40px (lists, attendees, roles)
  - **Medium**: 80px (reserved)
  - **Large**: 150px (profiles)
- Photo support for:
  - Members (profiles with photos)
  - Gatherings (event photos with 60x60 thumbnails in list)

### 🎨 Liquid Glass Design
- Complete glassmorphism design system:
  - `.ultraThinMaterial` blur effects
  - Gradient borders with opacity
  - Depth shadows
  - Smooth animations with spring physics
  - Animated backgrounds with gradients and blur circles
  - AppIcon watermark (400x400, 5% opacity)
- Reusable components:
  - `GlassCard`, `GlassRow`, `GlassButtonStyle`
  - `GlassBackground` with animation
- Automatic light/dark mode adaptation
- List background opacity at 30% for greater transparency

## 🛠️ Technology Stack

### Frameworks and Technologies
- **SwiftUI**: Declarative UI framework
- **SwiftData**: Modern persistence (schema-driven)
- **MapKit**: Map integration and geocoding
- **Charts**: Charts framework (iOS 16+)
- **UIKit**: UIImagePickerController for camera

### Architecture
- **MVVM Pattern**: Models, Views with reactive `@Query`
- **Main Actor Isolation**: Configured by default
- **Swift Concurrency**: async/await, actors
- **Cascade Deletion**: Relationships with cascade deletion

### Requirements
- **Xcode**: 26.0.1
- **iOS**: 26.0+
- **Swift**: 5.0
- **Devices**: iPhone and iPad (Universal)

### Localization
- **Dates**: Spanish (es_ES)
- **Currency**: Argentine Peso (es_AR)

## 📂 Project Structure

```
AppPenia/
├── Models/
│   ├── Event.swift          # Gathering entity
│   ├── User.swift           # Member entity
│   ├── Attendance.swift     # Many-to-many relationship
│   ├── Expense.swift        # Expenses with debt calculation
│   └── Payment.swift        # Payment records
├── Views/
│   ├── MainTabView.swift    # Main navigation (4 tabs)
│   ├── EventsListView.swift # Gatherings list
│   ├── EventDetailView.swift # Gathering detail
│   ├── EditEventView.swift  # Gathering editing
│   ├── UsersListView.swift  # Members list
│   ├── UserProfileView.swift # Member profile
│   ├── EditUserView.swift   # Member editing
│   ├── EditPhotoView.swift  # Photo management
│   ├── StatisticsView.swift # Charts and statistics
│   ├── ExpensesTabView.swift # Expenses list
│   ├── AddExpenseView.swift # Add expense
│   └── ExpenseDetailView.swift # Expense detail
├── Components/
│   ├── GlassComponents.swift # Glass design system
│   ├── ProfilePhotoView.swift # Reusable avatars
│   ├── CameraView.swift     # Camera wrapper
│   └── SedeMapView.swift    # Map component
└── AppPeniaApp.swift        # App entry point
```

## 🔧 Featured Technical Characteristics

### Data Models (SwiftData)
- **Event**: Gatherings with relationships to User (roles), Attendance, Expense
- **User**: Members with photo, birthday, headquarters, relationships to Attendance
- **Attendance**: Join table with cascade deletion
- **Expense**: Uses `Decimal` for financial precision
- **Payment**: Multiple payers per expense

### Debt Optimization Algorithm
```
1. Calculate net balance per user (paid - owed)
2. Separate into creditors (+) and debtors (-)
3. Sort by absolute amount descending
4. Match largest creditor with largest debtor
5. Transfer minimum of both amounts
6. Update balances and repeat
Result: Minimum number of transactions
```

### Reusable Components
- **ProfilePhotoView**: 3 configurable sizes with fallback
- **SedeMapView**: Async geocoding with states (loading, error, success)
- **GlassBackground**: Animated background with gradients and blur
- **CameraView**: UIViewControllerRepresentable for photo capture

### Data Relationships
- Many-to-many: User ↔ Event (via Attendance)
- One-to-one: Event → Expense (optional)
- One-to-many: Expense → Payment
- Automatic cascade deletion

---

**Bundle Identifier**: `PabloSegovia.AppPenia`

**Target**: iOS 26.0+ • iPhone & iPad
