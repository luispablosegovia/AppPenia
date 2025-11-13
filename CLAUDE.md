# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AppPenia is a SwiftUI-based iOS application for managing weekly event attendance. Built with Xcode 26.0.1, targeting iOS 26.0. The project uses Swift 5.0 with modern concurrency features and SwiftData for persistence.

## Purpose

The app manages attendance tracking for weekly events (occurring every Wednesday), allowing:
- Registration of users and events
- Tracking which users attended which events
- Viewing attendance history per user
- Viewing attendee lists per event
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
│   ├── MainTabView.swift    - Tab-based navigation (Events/Users)
│   ├── EventsListView.swift - Events list with add/delete functionality
│   ├── EventDetailView.swift - Event detail with attendance management
│   ├── UsersListView.swift  - Users list with add/delete functionality
│   └── UserProfileView.swift - User profile with attendance history
├── AppPeniaApp.swift        - App entry point with SwiftData configuration
└── ContentView.swift        - Wrapper redirecting to MainTabView
```

### Data Models (SwiftData)

**Event**: Events with date and optional notes
- `@Attribute(.unique) var id: UUID`
- `var date: Date` - Event date
- `var notes: String` - Optional event notes
- `@Relationship(deleteRule: .cascade)` with Attendance

**User**: Registered users
- `@Attribute(.unique) var id: UUID`
- `var name: String` - User's name
- `var createdAt: Date` - Registration date
- `@Relationship(deleteRule: .cascade)` with Attendance

**Attendance**: Many-to-many relationship between Users and Events
- Links a User to an Event
- Cascade deletion when User or Event is deleted

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

### Events Management
- List view with events sorted by date (most recent first)
- Create new events with date picker and optional notes
- View event details with attendee list
- Add multiple attendees to an event via multi-select interface
- Delete attendees from events (swipe to delete)
- Delete entire events (swipe to delete in list)

### Users Management
- List view with users sorted alphabetically
- Create new users with name validation
- View user profile with attendance statistics
- See complete attendance history per user (sorted by date)
- Delete users (swipe to delete)

### Data Relationships
- Many-to-many relationship between Users and Events via Attendance entity
- Cascade deletion: removing a User or Event automatically removes related Attendance records
- Bidirectional navigation: tap on a user in event detail to see their profile, tap on an event in user profile to see event details

### UI Features
- Tab-based navigation (Events / Users)
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
