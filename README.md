# AppPenia

Aplicación iOS para gestionar la asistencia a juntadas semanales.

## Descripción

AppPenia es una app SwiftUI que permite registrar miembros, crear juntadas (reuniones semanales), asignar roles (sede, cocinero, lavaplatos) y llevar un historial de asistencias.

## Características

- ✅ Gestión de miembros con fotos de perfil
- ✅ Calendario de juntadas con asignación de roles
- ✅ Historial de asistencias por miembro
- ✅ Estadísticas de participación
- ✅ Diseño glassmorphism moderno
- ✅ Persistencia con SwiftData

## Stack Tecnológico

- **SwiftUI** - Framework UI declarativo
- **SwiftData** - Persistencia de datos
- **MVVM** - Patrón arquitectónico
- **iOS 26.0+** - Target mínimo

## Requisitos

- Xcode 26.0.1+
- iOS 26.0+
- Swift 5.0+

## Compilación

```bash
# Build debug
xcodebuild -project AppPenia.xcodeproj -scheme AppPenia -configuration Debug build

# Build release
xcodebuild -project AppPenia.xcodeproj -scheme AppPenia -configuration Release build

# Clean
xcodebuild -project AppPenia.xcodeproj -scheme AppPenia clean
```

## Estructura del Proyecto

```
AppPenia/
├── Models/          # Entidades SwiftData (Event, User, Attendance)
├── Views/           # Vistas SwiftUI
├── Components/      # Componentes reutilizables
└── AppPeniaApp.swift
```

## Licencia

Proyecto privado - © Pablo Segovia
