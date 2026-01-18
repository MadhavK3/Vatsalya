# MVVM Architecture Documentation

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐              ┌──────────────┐            │
│  │     VIEW     │◄─────────────┤  VIEWMODEL   │            │
│  │              │              │              │            │
│  │  • Pages     │  Observes    │  • Providers │            │
│  │  • Widgets   │   State      │  • State Mgmt│            │
│  │  • UI Only   │              │  • UI Logic  │            │
│  └──────────────┘              └───────┬──────┘            │
│                                        │                     │
│                                  Calls │                     │
└────────────────────────────────────────┼─────────────────────┘
                                         │
┌────────────────────────────────────────┼─────────────────────┐
│                     DOMAIN LAYER       │                     │
├────────────────────────────────────────┼─────────────────────┤
│                                        ▼                     │
│  ┌────────────────────────────────────────────────┐         │
│  │              SERVICES                          │         │
│  │  • AuthService                                 │         │
│  │  • GeminiService                               │         │
│  │  • SmartReminderEngine                         │         │
│  │  • Business Logic                              │         │
│  └────────────────┬───────────────────────────────┘         │
│                   │                                          │
│                   │ Uses                                     │
└───────────────────┼──────────────────────────────────────────┘
                    │
┌───────────────────┼──────────────────────────────────────────┐
│                   │         DATA LAYER                       │
├───────────────────┼──────────────────────────────────────────┤
│                   ▼                                          │
│  ┌────────────────────────────────────────────────┐         │
│  │           REPOSITORIES                         │         │
│  │  • FeedingRepository                          │         │
│  │  • SleepRepository                            │         │
│  │  • VaccinationRepository                      │         │
│  │  • ... (14 repositories)                      │         │
│  └────────────────┬───────────────────────────────┘         │
│                   │                                          │
│                   │ Uses                                     │
│                   ▼                                          │
│  ┌────────────────────────────────────────────────┐         │
│  │              MODELS                            │         │
│  │  • FeedingModel                               │         │
│  │  • SleepModel                                 │         │
│  │  • VaccinationModel                           │         │
│  │  • ... (15 models)                            │         │
│  └────────────────┬───────────────────────────────┘         │
│                   │                                          │
│                   │ Persists                                 │
│                   ▼                                          │
│  ┌────────────────────────────────────────────────┐         │
│  │         LOCAL STORAGE (Hive)                  │         │
│  │         REMOTE STORAGE (Supabase)             │         │
│  └───────────────────────────────────────────────┘         │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Layer Details

### 1. Presentation Layer (`lib/presentation/`)

#### ViewModels (`lib/presentation/viewmodels/`)
**Responsibility**: State management and presentation logic

| File | Purpose |
|------|---------|
| `auth_provider.dart` | Authentication state management |
| `user_provider.dart` | Current user state |
| `user_meta_provider.dart` | User metadata (role, dates) |
| `repository_providers.dart` | Repository instances |
| `ai_provider.dart` | AI chat state and logic |
| `smart_reminder_provider.dart` | Smart reminder generation |
| `viewmodels.dart` | Barrel export file |

**Key Characteristics**:
- Uses Riverpod for state management
- No direct UI code
- Coordinates between Services and Repositories
- Provides data to Views
- Handles user actions

**Example**:
```dart
final userProfileProvider = Provider<UserProfileType?>((ref) {
  final user = ref.watch(currentUserProvider);
  // Transform data for UI consumption
  return user?.userMetadata?['role'];
});
```

#### Views (`lib/presentation/pages/` & `lib/presentation/widgets/`)

**Pages** - Full screens:
- `auth_page.dart` - Authentication screen
- `dashboard_page.dart` - Main dashboard
- `pregnancy_tracking_page.dart` - Pregnancy tracking
- `feeding_tracking_page.dart` - Feeding logs
- ... (31 pages total)

**Widgets** - Reusable components:
- `customizable_dashboard.dart` - Dashboard builder
- `progress_chart.dart` - Chart widget
- `contraction_timer_widget.dart` - Timer UI
- ... (13 widgets total)

**Key Characteristics**:
- Pure UI code
- Observes ViewModel state
- Handles user input
- No business logic

**Example**:
```dart
class DashboardPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    // UI code only
  }
}
```

### 2. Domain Layer (`lib/domain/`)

#### Services (`lib/domain/services/`)
**Responsibility**: Business logic and external integrations

| File | Purpose |
|------|---------|
| `auth_service.dart` | Supabase authentication logic |
| `gemini_service.dart` | Google Gemini AI integration |
| `smart_reminder_engine.dart` | Intelligent reminder generation |

**Key Characteristics**:
- Framework-independent business logic
- Reusable across different platforms
- No UI dependencies
- Uses Repositories for data

**Example**:
```dart
class SmartReminderEngine {
  Future<List<ReminderModel>> generateReminders(UserProfile profile) {
    // Complex business logic for generating reminders
  }
}
```

#### Entities (`lib/domain/entities/`)
**Responsibility**: Business entities (future use)
- Currently empty, reserved for domain-specific entities
- Different from data models (DTOs)

### 3. Data Layer (`lib/data/`)

#### Repositories (`lib/data/repositories/`)
**Responsibility**: Data access and persistence

| Repository | Purpose |
|------------|---------|
| `feeding_repository.dart` | Feeding data CRUD |
| `sleep_repository.dart` | Sleep data CRUD |
| `vaccination_repository.dart` | Vaccination data CRUD |
| `pregnancy_repository.dart` | Pregnancy data CRUD |
| `growth_repository.dart` | Growth tracking CRUD |
| `diaper_repository.dart` | Diaper log CRUD |
| `reminder_repository.dart` | Reminder CRUD |
| `chat_history_repository.dart` | AI chat history CRUD |
| ... (14 repositories total) |

**Key Characteristics**:
- Abstracts data sources
- Implements CRUD operations
- Uses Hive for local storage
- Can integrate with APIs

**Example**:
```dart
class FeedingRepository {
  Future<void> addFeeding(FeedingModel feeding) async {
    final box = await Hive.openBox<FeedingModel>('feedings');
    await box.add(feeding);
  }
}
```

#### Models (`lib/data/models/`)
**Responsibility**: Data transfer objects

| Model | Purpose |
|-------|---------|
| `feeding_model.dart` | Feeding entry structure |
| `sleep_model.dart` | Sleep entry structure |
| `vaccination_model.dart` | Vaccination record |
| `pregnancy_model.dart` | Pregnancy data |
| `chat_message_model.dart` | AI chat message |
| `reminder_model.dart` | Reminder structure |
| ... (15 models total) |

**Key Characteristics**:
- Hive type adapters for serialization
- JSON serialization support
- Immutable data classes

**Example**:
```dart
@HiveType(typeId: 1)
class FeedingModel extends HiveObject {
  @HiveField(0)
  final DateTime timestamp;
  
  @HiveField(1)
  final String type; // breast/formula/solid
  
  @HiveField(2)
  final double? quantity;
}
```

#### Local Storage (`lib/data/local/`)
- `hive_adapters.dart` - Registers all Hive type adapters

### 4. Core Layer (`lib/core/`)

#### Constants (`lib/core/constants/`)
- `app_constants.dart` - App-wide constants
- `env.dart` - Environment variables

#### Theme (`lib/core/theme/`)
- `app_theme.dart` - Material 3 theme configuration

#### Utils (`lib/core/utils/`)
- `notification_service.dart` - Local notifications
- `reminder_service.dart` - Reminder scheduling
- `vaccination_schedule.dart` - Vaccination data

## Data Flow

### User Action → Data Persistence
```
User Interaction
       ↓
View (Widget)
       ↓
ViewModel (Provider)
       ↓
Service (Business Logic)
       ↓
Repository (Data Access)
       ↓
Model (Data Structure)
       ↓
Storage (Hive/Supabase)
```

### Data Retrieval → UI Update
```
Storage (Hive/Supabase)
       ↓
Model (Data Structure)
       ↓
Repository (Data Access)
       ↓
Service (Business Logic)
       ↓
ViewModel (Provider) ← State Change
       ↓
View (Widget) ← UI Update
       ↓
User sees updated UI
```

## MVVM Benefits in This Project

### 1. **Testability**
- ViewModels can be unit tested independently
- Business logic isolated from UI
- Mock repositories for testing

### 2. **Maintainability**
- Clear separation of concerns
- Each file has a single responsibility
- Easy to locate and modify code

### 3. **Scalability**
- Add new features without touching existing code
- Reuse ViewModels across different Views
- Services can be shared across the app

### 4. **Developer Experience**
- Clear structure for new developers
- Standard patterns and practices
- Easy onboarding

## Best Practices

### ViewModels
✅ **DO**:
- Keep ViewModels focused on a single feature
- Use Riverpod for state management
- Coordinate between Services and Repositories
- Transform data for UI consumption

❌ **DON'T**:
- Include UI code in ViewModels
- Access widgets or BuildContext
- Directly access storage (use Repositories)

### Views
✅ **DO**:
- Keep Views purely focused on UI
- Use ConsumerWidget for state observation
- Handle user input and navigation
- Display data from ViewModels

❌ **DON'T**:
- Include business logic in Views
- Directly access Repositories or Services
- Manage complex state

### Services
✅ **DO**:
- Implement core business logic
- Be framework-independent
- Use Repositories for data access
- Return domain-specific types

❌ **DON'T**:
- Access UI or widgets
- Manage state (that's ViewModel's job)
- Directly access storage

### Repositories
✅ **DO**:
- Abstract data sources
- Implement CRUD operations
- Handle error cases
- Return Models

❌ **DON'T**:
- Include business logic
- Access UI components
- Manage application state

## Example Flow: Adding a Feeding Entry

```dart
// 1. User taps "Save" in FeedingTrackingPage (View)
onPressed: () {
  final feeding = FeedingModel(...);
  // Call ViewModel
  await ref.read(feedingRepositoryProvider).addFeeding(feeding);
}

// 2. Repository handles persistence (Repository)
class FeedingRepository {
  Future<void> addFeeding(FeedingModel feeding) async {
    final box = await Hive.openBox<FeedingModel>('feedings');
    await box.add(feeding);
  }
}

// 3. ViewModel provides updated data (ViewModel)
final feedingsProvider = FutureProvider<List<FeedingModel>>((ref) async {
  final repo = ref.read(feedingRepositoryProvider);
  return await repo.getFeedings();
});

// 4. View displays updated list (View)
Widget build(BuildContext context, WidgetRef ref) {
  final feedings = ref.watch(feedingsProvider);
  return feedings.when(
    data: (list) => ListView(...),
    loading: () => CircularProgressIndicator(),
    error: (e, s) => ErrorWidget(e),
  );
}
```

## Migration Path

This project was migrated from a previous structure to proper MVVM:

**Changes Made**:
1. Moved `lib/domain/providers/` → `lib/presentation/viewmodels/`
2. Moved `lib/data/services/` → `lib/domain/services/`
3. Updated all import statements
4. Created barrel export file

**See**: `MVVM_MIGRATION.md` for detailed migration steps

## References

- [Flutter MVVM Best Practices](https://flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
