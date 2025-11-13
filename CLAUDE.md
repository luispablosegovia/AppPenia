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
│   ├── User.swift           - User entity with name, attendances relationship
│   └── Attendance.swift     - Join entity connecting Users and Events
├── Views/
│   ├── MainTabView.swift    - Tab-based navigation (Juntadas/Miembros)
│   ├── EventsListView.swift - Gatherings list with add/delete functionality
│   ├── EventDetailView.swift - Gathering detail with attendance management
│   ├── UsersListView.swift  - Members list with add/delete functionality
│   └── UserProfileView.swift - Member profile with attendance history
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
- `@Relationship(deleteRule: .cascade)` with Attendance
- Computed properties: `attendanceCount`, `age`, `formattedBirthday`

**Attendance**: Many-to-many relationship between Users and Events
- Links a Member to a Gathering
- Cascade deletion when Member or Gathering is deleted

### Tech Stack

- **SwiftUI**: Declarative UI framework
- **SwiftData**: Modern persistence framework (replacing Core Data)
- **MVVM Pattern**: Models, Views with `@Query` for reactive data
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
- Required role assignments: sede (host), cook, and dishwasher
- Host selection limited to members with sede registered
- View gathering details with full information (date, sede with address, cook, dishwasher, attendee list)
- List rows display host information with house emoji
- Add multiple attendees to a gathering via multi-select interface
- Delete attendees from gatherings (swipe to delete)
- Delete entire gatherings (swipe to delete in list)

### Members Management (Miembros)
- List view with members sorted alphabetically
- Create new members with name validation
- Optional birthday field with age calculation
- Optional sede (headquarters) information with address
- View member profile with full information (birthday, age, sede, address)
- Statistics section showing: times hosted, times cooked, times washed
- Attendance statistics showing total count
- See complete attendance history per member (sorted by date)
- Delete members (swipe to delete)

### Data Relationships
- Many-to-many relationship between Members and Gatherings via Attendance entity
- Cascade deletion: removing a Member or Gathering automatically removes related Attendance records
- Bidirectional navigation: tap on a member in gathering detail to see their profile, tap on a gathering in member profile to see gathering details

### UI Features
- Tab-based navigation (Juntadas / Miembros)
- Modal sheets for creating new records
- NavigationStack for hierarchical navigation
- ContentUnavailableView for empty states
- Locale-aware date formatting (Spanish - es_ES)

## SwiftData Configuration

The app uses a shared ModelContainer configured in `AppPeniaApp.swift`:
- Schema includes: Event, User, Attendance
- Persistent storage (not in-memory)
- Container injected via `.modelContainer()` modifier
- Views access data via `@Query` property wrapper
- Mutations via `@Environment(\.modelContext)`

## Important Notes

- All views that use SwiftData must import both `SwiftUI` and `SwiftData`
- Preview providers need `.modelContainer(for: [Event.self, User.self, Attendance.self])` modifier
- The app entry point is `MainTabView`, not the default `ContentView`
- Date formatting is configured for Spanish locale (es_ES)

## Project Configuration

- Automatic code signing is enabled (`CODE_SIGN_STYLE = Automatic`)
- SwiftUI Previews are enabled (`ENABLE_PREVIEWS = YES`)
- Info.plist is auto-generated (`GENERATE_INFOPLIST_FILE = YES`)
- String catalog symbol generation is enabled for localization
