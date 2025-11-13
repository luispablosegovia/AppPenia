# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AppPenia is a SwiftUI-based iOS application for managing weekly gathering attendance ("juntadas"). Built with Xcode 26.0.1, targeting iOS 26.0. The project uses Swift 5.0 with modern concurrency features and SwiftData for persistence.

## Purpose

The app manages attendance tracking for weekly gatherings (occurring every Wednesday), allowing:
- Registration of members and gatherings
- Tracking which members attended which gatherings
- Viewing attendance history per member
- Viewing attendee lists per gathering
- Total attendance counts

## Architecture

**MVVM Architecture with SwiftData**

### Project Structure

```
AppPenia/
├── Models/
│   ├── Event.swift          - Event entity with date, notes, attendances relationship
│   ├── User.swift           - User entity with name, photo, attendances relationship
│   └── Attendance.swift     - Join entity connecting Users and Events
├── Views/
│   ├── MainTabView.swift    - Tab-based navigation (Juntadas/Miembros/Estadísticas)
│   ├── EventsListView.swift - Gatherings list with add/delete functionality
│   ├── EventDetailView.swift - Gathering detail with attendance management
│   ├── EditEventView.swift  - Edit existing gathering information
│   ├── UsersListView.swift  - Members list with add/delete functionality
│   ├── UserProfileView.swift - Member profile with attendance history
│   ├── EditUserView.swift   - Edit existing member information
│   ├── EditPhotoView.swift  - Edit/delete member photos
│   └── StatisticsView.swift - Overall statistics and insights
├── Components/
│   ├── GlassComponents.swift - Reusable glassmorphism UI components
│   ├── ProfilePhotoView.swift - Reusable avatar component with multiple sizes
│   └── CameraView.swift     - UIImagePickerController wrapper for camera access
├── AppPeniaApp.swift        - App entry point with SwiftData configuration
└── ContentView.swift        - Wrapper redirecting to MainTabView
```

### Data Models (SwiftData)

**Event**: Gatherings (juntadas) with date, optional notes, and role assignments
- `@Attribute(.unique) var id: UUID`
- `var date: Date` - Gathering date
- `var notes: String` - Optional gathering notes
- `var host: User?` - Member who provides the sede (headquarters)
- `var cook: User?` - Member who cooks
- `var dishwasher: User?` - Member who washes/cleans
- `@Relationship(deleteRule: .cascade)` with Attendance
- Computed properties: `attendeeCount`, `formattedDate`, `hostAddress`

**User**: Registered members (miembros)
- `@Attribute(.unique) var id: UUID`
- `var name: String` - Member's name
- `var createdAt: Date` - Registration date
- `var birthday: Date?` - Optional birthday
- `var hasSede: Bool` - Whether the member has a sede (headquarters)
- `var address: String` - Sede address (empty if no sede)
- `var photoData: Data?` - Profile photo stored as JPEG data
- `@Relationship(deleteRule: .cascade)` with Attendance
- Computed properties: `attendanceCount`, `age`, `formattedBirthday`

**Attendance**: Many-to-many relationship between Users and Events
- Links a Member to a Gathering
- Cascade deletion when Member or Gathering is deleted

### Tech Stack

- **SwiftUI**: Declarative UI framework
- **SwiftData**: Modern persistence framework (replacing Core Data)
- **MVVM Pattern**: Models, Views with `@Query` for reactive data
- **Liquid Glass Design System**: Modern glassmorphism UI with blur effects, transparency, and animations
- **Main actor isolation**: Enabled by default (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- **Swift approachable concurrency**: `SWIFT_APPROACHABLE_CONCURRENCY = YES`
- **SwiftUI Previews**: Development (`#Preview` macro)

## Build and Run

**Build the project:**
```bash
xcodebuild -project AppPenia.xcodeproj -scheme AppPenia -configuration Debug build
```

**Build for release:**
```bash
xcodebuild -project AppPenia.xcodeproj -scheme AppPenia -configuration Release build
```

**Clean build folder:**
```bash
xcodebuild -project AppPenia.xcodeproj -scheme AppPenia clean
```

## Development

**Opening the project:**
Open `AppPenia.xcodeproj` in Xcode to work with the visual editor, storyboards, and run on simulators/devices.

**Bundle identifier:**
`PabloSegovia.AppPenia`

**Supported devices:**
iPhone and iPad (Universal app - `TARGETED_DEVICE_FAMILY = "1,2"`)

**Deployment target:**
iOS 26.0

## Key Features Implemented

### Gatherings Management (Juntadas)
- List view with gatherings sorted by date (most recent first)
- Create new gatherings with date picker, optional notes, and role assignments
- **Edit gatherings** - Modify date, notes, and role assignments via modal sheet
- Required role assignments: sede (host), cook, and dishwasher
- Host selection limited to members with sede registered
- View gathering details with full information (date, sede with address, cook, dishwasher, attendee list)
- List rows display host information with house emoji and avatar
- **Profile photos displayed** for host, cook, dishwasher, and all attendees
- Add multiple attendees to a gathering via multi-select interface (with avatars)
- Delete attendees from gatherings (swipe to delete)
- Delete entire gatherings (swipe to delete in list)

### Members Management (Miembros)
- List view with members sorted alphabetically **with profile photo avatars**
- Create new members with name validation and **optional photo capture**
- **Camera integration** - Take photos during member creation with UIImagePickerController
- **Edit member profiles** - Modify name, birthday, sede information via modal sheet
- **Photo management** - Change or delete member photos from profile view
- Optional birthday field with age calculation
- Optional sede (headquarters) information with address
- View member profile with **large profile photo**, full information (birthday, age, sede, address)
- Statistics section showing: times hosted, times cooked, times washed
- Attendance statistics showing total count
- See complete attendance history per member (sorted by date)
- Delete members (swipe to delete)

### Data Relationships
- Many-to-many relationship between Members and Gatherings via Attendance entity
- Cascade deletion: removing a Member or Gathering automatically removes related Attendance records
- Bidirectional navigation: tap on a member in gathering detail to see their profile, tap on a gathering in member profile to see gathering details

### UI Features
- Tab-based navigation (Juntadas / Miembros) with glass effect TabBar
- Liquid glass design with glassmorphism effects throughout the app
- Glass cards for list items with tap animations (scale + brightness)
- Glass backgrounds with animated gradients (blue/purple/pink)
- Glass buttons with material blur and gradient borders
- Modal sheets for creating new records with glass styling
- NavigationStack for hierarchical navigation
- Custom empty states with glass cards
- Locale-aware date formatting (Spanish - es_ES)
- Smooth animations with spring physics

## SwiftData Configuration

The app uses a shared ModelContainer configured in `AppPeniaApp.swift`:
- Schema includes: Event, User, Attendance
- Persistent storage (not in-memory)
- Container injected via `.modelContainer()` modifier
- Views access data via `@Query` property wrapper
- Mutations via `@Environment(\.modelContext)`

## Liquid Glass Design System

The app implements a comprehensive glassmorphism design system with reusable components in `Components/GlassComponents.swift`:

**Reusable Components:**
- `GlassBackground` - Animated gradient background with decorative blur circles and centered AppIcon watermark (400x400, 5% opacity)
- `GlassCard` modifier (`.glassCard()`) - Applies glass effect to any view with tap animations
- `GlassRow` - Pre-configured glass card wrapper for list items
- `GlassButtonStyle` - Button style with glass effect and press animations
- `glassListBackground()` modifier - Combines glass background with hidden scroll background
- `ProfilePhotoView` - Circular avatar component with three sizes (small: 40px, medium: 80px, large: 150px)
- `CameraView` - UIViewControllerRepresentable for camera photo capture with editing enabled

**Design Characteristics:**
- `.ultraThinMaterial` blur effect for intense glassmorphism
- Gradient borders with white opacity (0.6 to 0.2)
- Shadow effects for depth (black 15% opacity, 10px radius)
- Spring animations (0.3s response, 0.6 damping fraction)
- Scale (0.97x) and brightness (-5%) on press
- Adaptive system colors for light/dark mode compatibility

**Usage Pattern:**
```swift
// Apply to entire List view
List { ... }
    .glassListBackground()

// Wrap list items
GlassRow {
    YourContentView()
}

// Style buttons
Button("Label") { action }
    .buttonStyle(GlassButtonStyle())
```

## Photo Management

The app includes comprehensive photo capture and display functionality:

**Camera Permissions:**
- `NSCameraUsageDescription` configured in Info.plist: "Necesitamos acceso a la cámara para tomar fotos de los miembros"

**Photo Storage:**
- Photos stored as `Data?` in User model using JPEG compression (0.8 quality)
- Photos persist in SwiftData automatically with cascade deletion

**Photo Capture Flow:**
1. User taps "Tomar Foto" button in AddUserView or EditPhotoView
2. CameraView presents UIImagePickerController with camera source
3. Editing enabled for cropping/adjusting before capture
4. Image converted to JPEG Data and stored in User.photoData

**Photo Display:**
- Small avatars (40px) in: UserRow, EventDetailView (attendees, roles), AddAttendeeView
- Medium avatars (80px): Reserved for future use
- Large photos (150px): UserProfileView, EditPhotoView
- Fallback: `person.circle.fill` SF Symbol when no photo exists
- All photos have glass-style borders and shadows

## Important Notes

- All views that use SwiftData must import both `SwiftUI` and `SwiftData`
- Preview providers need `.modelContainer(for: [Event.self, User.self, Attendance.self])` modifier
- The app entry point is `MainTabView`, not the default `ContentView`
- Date formatting is configured for Spanish locale (es_ES)
- Glass components require iOS 15+ for `.ultraThinMaterial` support
- Camera access requires physical device (not available in simulator)
- Photos stored in SwiftData; no external photo library integration

## Project Configuration

- Automatic code signing is enabled (`CODE_SIGN_STYLE = Automatic`)
- SwiftUI Previews are enabled (`ENABLE_PREVIEWS = YES`)
- Info.plist is auto-generated (`GENERATE_INFOPLIST_FILE = YES`)
- Camera usage description configured (`INFOPLIST_KEY_NSCameraUsageDescription`)
- String catalog symbol generation is enabled for localization