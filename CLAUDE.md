# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AppPenia is a SwiftUI-based iOS application for managing weekly gathering attendance ("juntadas") with integrated expense tracking and location services. Built with Xcode 26.0.1, targeting iOS 26.0. The project uses Swift 5.0 with modern concurrency features and SwiftData for persistence.

## Purpose

The app manages attendance tracking for weekly gatherings (occurring every Wednesday), allowing:
- Registration of members and gatherings
- Tracking which members attended which gatherings
- Viewing attendance history per member
- Viewing attendee lists per gathering
- Total attendance counts
- **Shared expense tracking with automatic debt simplification**
- **MapKit integration for sede (headquarters) visualization**
- **Comprehensive statistics with SwiftUI Charts**

## Architecture

**MVVM Architecture with SwiftData**

### Project Structure

```
AppPenia/
├── Models/
│   ├── Event.swift          - Event entity with date, notes, roles, expense relationship
│   ├── User.swift           - User entity with name, photo, birthday, sede, attendances
│   ├── Attendance.swift     - Join entity connecting Users and Events
│   ├── Expense.swift        - Expense tracking with automatic debt calculation
│   └── Payment.swift        - Payment records for expenses
├── Views/
│   ├── MainTabView.swift    - 4-tab navigation (Juntadas/Miembros/Gastos/Estadísticas)
│   ├── EventsListView.swift - Gatherings list with add/delete functionality
│   ├── EventDetailView.swift - Gathering detail with attendance, expenses, and map
│   ├── EditEventView.swift  - Edit existing gathering information
│   ├── UsersListView.swift  - Members list with add/delete functionality
│   ├── UserProfileView.swift - Member profile with attendance history, financial balance, and map
│   ├── EditUserView.swift   - Edit existing member information with live map preview
│   ├── EditPhotoView.swift  - Edit/delete member photos
│   ├── StatisticsView.swift - Statistics with 4 chart types (SwiftUI Charts)
│   ├── ExpensesTabView.swift - List of gatherings with expenses
│   ├── AddExpenseView.swift - Add expense to gathering with multi-payer support
│   └── ExpenseDetailView.swift - Expense detail with optimized debt breakdown
├── Components/
│   ├── GlassComponents.swift - Reusable glassmorphism UI components
│   ├── ProfilePhotoView.swift - Reusable avatar component with multiple sizes
│   ├── CameraView.swift     - UIImagePickerController wrapper for camera access
│   └── SedeMapView.swift    - MapKit integration for address visualization
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
- `@Relationship(deleteRule: .cascade)` with Expense (optional one-to-one)
- Computed properties: `attendeeCount`, `formattedDate`, `hostAddress`, `hasExpense`

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
- `@Attribute(.unique) var id: UUID`
- `var createdAt: Date` - Creation timestamp
- `var user: User?` - Relationship to member
- `var event: Event?` - Relationship to gathering
- Cascade deletion when Member or Gathering is deleted

**Expense**: Expense tracking for gatherings with automatic debt calculation
- `@Attribute(.unique) var id: UUID`
- `var totalAmount: Decimal` - Total expense amount (uses Decimal for precision)
- `var createdAt: Date` - Creation timestamp
- `var event: Event?` - Associated gathering
- `@Relationship(deleteRule: .cascade)` with Payment
- Computed properties: `amountPerPerson`, `totalPaid`, `isBalanced`
- Methods: `calculateDebts()` (greedy algorithm for debt optimization), `balanceFor(user:)`, `amountPaidBy(user:)`

**Payment**: Payment records for expenses
- `@Attribute(.unique) var id: UUID`
- `var amount: Decimal` - Payment amount
- `var createdAt: Date` - Creation timestamp
- `var user: User?` - Member who paid
- `var expense: Expense?` - Associated expense

**Debt** (Struct - not persisted): Result of debt calculation
- `var id: UUID` - Auto-generated identifier
- `var from: User` - Debtor
- `var to: User` - Creditor
- `var amount: Decimal` - Amount to transfer

### Tech Stack

- **SwiftUI**: Declarative UI framework
- **SwiftData**: Modern persistence framework (replacing Core Data)
- **MapKit**: Map integration and geocoding for sede visualization
  - MKLocalSearch for address geocoding
  - MapCameraPosition for camera control
  - Marker API for custom pins with house icons
- **Charts**: SwiftUI Charts framework for statistics visualization (iOS 16+)
- **MVVM Pattern**: Models, Views with `@Query` for reactive data
- **Liquid Glass Design System**: Modern glassmorphism UI with blur effects, transparency, and animations
- **Main actor isolation**: Enabled by default (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- **Swift approachable concurrency**: `SWIFT_APPROACHABLE_CONCURRENCY = YES`, async/await patterns
- **SwiftUI Previews**: Development (`#Preview` macro)
- **Localization**: Spanish (es_ES) for dates, Argentine Peso (es_AR) for currency formatting

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
- **Interactive map display** of host's sede location with address geocoding
- List rows display host information with house emoji and avatar
- **Profile photos displayed** for host, cook, dishwasher, and all attendees
- Add multiple attendees to a gathering via multi-select interface (with avatars)
- Delete attendees from gatherings (swipe to delete)
- Delete entire gatherings (swipe to delete in list with confirmation)
- **Link expenses to gatherings** - View and manage gathering expenses from detail view

### Members Management (Miembros)
- List view with members sorted alphabetically **with profile photo avatars**
- Create new members with name validation and **optional photo capture**
- **Camera integration** - Take photos during member creation with UIImagePickerController
- **Edit member profiles** - Modify name, birthday, sede information via modal sheet
- **Live map preview** when entering or editing sede address
- **Photo management** - Change or delete member photos from profile view
- Optional birthday field with age calculation
- Optional sede (headquarters) information with address
- View member profile with **large profile photo**, full information (birthday, age, sede, address)
- **Interactive map display** of member's sede location (if available)
- **Financial balance section** - Shows total contributed, total owed, amount owed to user, and net balance
- Statistics section showing: times hosted, times cooked, times washed
- Attendance statistics showing total count
- See complete attendance history per member (sorted by date)
- Delete members (swipe to delete with confirmation)

### Shared Expenses (Gastos)
- **Dedicated expenses tab** showing all gatherings with registered expenses
- **Add expense to gathering** with multi-payer support
  - Input total amount with decimal precision
  - Select multiple payers with checkboxes
  - Input individual payment amounts per payer
  - Real-time validation (payments must sum to total)
  - Automatic per-person calculation
- **Expense detail view** with comprehensive breakdown
  - Summary section (total amount, per-person amount, attendee count)
  - "Who paid" section showing all payers and amounts (green)
  - "Who pays whom" section with optimized debt transactions (cyan arrows)
  - Balance indicator (balanced/unbalanced)
  - Delete expense functionality
- **Automatic debt simplification** using greedy algorithm
  - Minimizes number of transactions required
  - Calculates net balance for each user
  - Optimally matches creditors with debtors
- **User financial balance** tracking across all gatherings
  - Total contributed (what user paid)
  - Total owed (what user owes to others)
  - Amount owed to user (what others owe to user)
  - Net balance with color coding (red for debt, green for credit)
  - Status messages ("Debe pagar", "Le deben", "Está al día")
- **Argentine Peso formatting** throughout expense views

### Statistics & Charts (Estadísticas)
- **Four comprehensive chart types** using SwiftUI Charts framework
  1. **Attendance by Member** - Horizontal bar chart (blue-to-purple gradient)
  2. **Sede Statistics** - Who hosted most often (orange-to-pink gradient)
  3. **Cook Statistics** - Cooking frequency (green-to-mint gradient)
  4. **Dishwasher Statistics** - Cleaning frequency (cyan-to-blue gradient)
- Custom axis labels and formatting
- Value annotations on each bar
- Glass card styling for chart containers
- Empty state handling
- Scrollable vertical layout with 40px spacing

### Map Integration (MapKit)
- **SedeMapView component** for address visualization
  - Geocodes addresses using MKLocalSearch API
  - Displays interactive map with realistic elevation
  - Custom marker with house icon
  - 500-meter zoom level for optimal viewing
  - Loading state with progress indicator
  - Error handling with user-friendly messages
  - Glass-style borders and shadows
  - Configurable height (default 250px)
  - Automatic update on address change
- **Map display locations**:
  - UserProfileView: Member's sede location
  - EventDetailView: Host's sede location
  - AddUserView: Live preview during member creation
  - EditUserView: Live preview during editing

### Data Relationships
- Many-to-many relationship between Members and Gatherings via Attendance entity
- One-to-one relationship between Event and Expense (optional)
- One-to-many relationship between Expense and Payment
- Cascade deletion: removing a Member, Gathering, or Expense automatically removes related records
- Bidirectional navigation: tap on a member in gathering detail to see their profile, tap on a gathering in member profile to see gathering details

### UI Features
- **4-tab navigation** (Juntadas / Miembros / Gastos / Estadísticas) with glass effect TabBar
- Liquid glass design with glassmorphism effects throughout the app
- Glass cards for list items with tap animations (scale + brightness)
- Glass backgrounds with animated gradients (blue/purple/pink)
- Glass buttons with material blur and gradient borders
- Modal sheets for creating new records with glass styling
- NavigationStack for hierarchical navigation
- Custom empty states with glass cards
- Locale-aware date formatting (Spanish - es_ES)
- Currency formatting (Argentine Peso - es_AR)
- Smooth animations with spring physics
- Loading states for async operations (geocoding, etc.)
- Confirmation alerts for destructive actions (delete)

## SwiftData Configuration

The app uses a shared ModelContainer configured in `AppPeniaApp.swift`:
- Schema includes: Event, User, Attendance, Expense, Payment
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
- `SedeMapView` - MapKit wrapper for geocoding and displaying addresses with custom house markers

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

## Debt Simplification Algorithm

The expense system uses a greedy optimization algorithm to minimize the number of transactions required to settle all debts:

**Algorithm Steps:**
1. Calculate net balance for each user (amount paid - amount owed)
2. Separate users into creditors (positive balance) and debtors (negative balance)
3. Sort both lists by absolute amount descending
4. Match largest creditor with largest debtor
5. Transfer minimum of both amounts
6. Update balances and move to next pair if settled
7. Result: Minimized transaction count

**Example:**
- Before: 6 potential transactions (everyone pays everyone)
- After: 2-3 optimized transactions (maximum efficiency)

## Map Geocoding Flow

The SedeMapView component handles address visualization:

**Geocoding Process:**
1. User enters address in text field
2. SedeMapView receives address via binding
3. Async geocoding with MKLocalSearch API
4. Shows loading state during search
5. Updates map camera on success with 500m zoom
6. Shows error state on failure
7. Reactive updates on address changes

**Features:**
- Handles natural language addresses
- Main actor isolation for UI updates
- Modern MapKit Camera API
- Realistic 3D terrain rendering
- Custom house icon markers

## Important Notes

- All views that use SwiftData must import both `SwiftUI` and `SwiftData`
- Preview providers need `.modelContainer(for: [Event.self, User.self, Attendance.self, Expense.self, Payment.self])` modifier
- The app entry point is `MainTabView`, not the default `ContentView`
- Date formatting is configured for Spanish locale (es_ES)
- Currency formatting uses Argentine Peso (es_AR) with NumberFormatter
- Glass components require iOS 15+ for `.ultraThinMaterial` support
- Camera access requires physical device (not available in simulator)
- Photos stored in SwiftData; no external photo library integration
- Map geocoding requires internet connection for address lookup
- **Expense amounts use Decimal type** for precise financial calculations (not Double)
- No expense editing implemented (delete and recreate only)

## Project Configuration

- Automatic code signing is enabled (`CODE_SIGN_STYLE = Automatic`)
- SwiftUI Previews are enabled (`ENABLE_PREVIEWS = YES`)
- Info.plist is auto-generated (`GENERATE_INFOPLIST_FILE = YES`)
- Camera usage description configured (`INFOPLIST_KEY_NSCameraUsageDescription`)
- String catalog symbol generation is enabled for localization
- to memorize