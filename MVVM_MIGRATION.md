# MVVM Architecture Migration Guide

## Overview
This document explains the migration from the previous structure to the new MVVM architecture.

## Changes Made

### 1. Directory Structure Changes

#### Moved `lib/domain/providers/` → `lib/presentation/viewmodels/`
**Rationale**: In MVVM, ViewModels (Riverpod Providers) belong to the Presentation layer as they handle presentation logic and state management.

**Files moved:**
- `ai_provider.dart`
- `auth_provider.dart`
- `repository_providers.dart`
- `smart_reminder_provider.dart`
- `user_meta_provider.dart`
- `user_provider.dart`

#### Moved `lib/data/services/` → `lib/domain/services/`
**Rationale**: Services contain business logic and should reside in the Domain layer, not the Data layer.

**Files moved:**
- `auth_service.dart`
- `gemini_service.dart`
- `smart_reminder_engine.dart`

### 2. Import Path Updates Required

All files that import from the old paths need to be updated:

#### Old Paths → New Paths

```dart
// ViewModels (Providers)
'package:maternal_infant_care/domain/providers/ai_provider.dart'
→ 'package:maternal_infant_care/presentation/viewmodels/ai_provider.dart'

'package:maternal_infant_care/domain/providers/auth_provider.dart'
→ 'package:maternal_infant_care/presentation/viewmodels/auth_provider.dart'

'package:maternal_infant_care/domain/providers/repository_providers.dart'
→ 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart'

'package:maternal_infant_care/domain/providers/smart_reminder_provider.dart'
→ 'package:maternal_infant_care/presentation/viewmodels/smart_reminder_provider.dart'

'package:maternal_infant_care/domain/providers/user_meta_provider.dart'
→ 'package:maternal_infant_care/presentation/viewmodels/user_meta_provider.dart'

'package:maternal_infant_care/domain/providers/user_provider.dart'
→ 'package:maternal_infant_care/presentation/viewmodels/user_provider.dart'

// Services
'package:maternal_infant_care/data/services/auth_service.dart'
→ 'package:maternal_infant_care/domain/services/auth_service.dart'

'package:maternal_infant_care/data/services/gemini_service.dart'
→ 'package:maternal_infant_care/domain/services/gemini_service.dart'

'package:maternal_infant_care/data/services/smart_reminder_engine.dart'
→ 'package:maternal_infant_care/domain/services/smart_reminder_engine.dart'
```

### 3. Simplified Import Using Barrel File

Instead of importing individual providers, you can now use:

```dart
// Before
import 'package:maternal_infant_care/presentation/viewmodels/auth_provider.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_provider.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';

// After (using barrel export)
import 'package:maternal_infant_care/presentation/viewmodels/viewmodels.dart';
```

## Automated Migration

To automatically update all imports, run the following PowerShell script:

```powershell
# Navigate to project root
cd "c:\Users\Om Bharambe\Desktop\hm\New folder\project carefree"

# Update domain/providers → presentation/viewmodels
Get-ChildItem -Path lib -Filter *.dart -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content = $content -replace 'domain/providers/ai_provider', 'presentation/viewmodels/ai_provider'
    $content = $content -replace 'domain/providers/auth_provider', 'presentation/viewmodels/auth_provider'
    $content = $content -replace 'domain/providers/repository_providers', 'presentation/viewmodels/repository_providers'
    $content = $content -replace 'domain/providers/smart_reminder_provider', 'presentation/viewmodels/smart_reminder_provider'
    $content = $content -replace 'domain/providers/user_meta_provider', 'presentation/viewmodels/user_meta_provider'
    $content = $content -replace 'domain/providers/user_provider', 'presentation/viewmodels/user_provider'
    
    # Update data/services → domain/services
    $content = $content -replace 'data/services/auth_service', 'domain/services/auth_service'
    $content = $content -replace 'data/services/gemini_service', 'domain/services/gemini_service'
    $content = $content -replace 'data/services/smart_reminder_engine', 'domain/services/smart_reminder_engine'
    
    Set-Content $_.FullName -Value $content -NoNewline
}
```

## Manual Cleanup

After running the automated migration:

1. Delete old directories:
   ```bash
   Remove-Item -Recurse -Force "lib\domain\providers"
   Remove-Item -Recurse -Force "lib\data\services"
   ```

2. Verify the app builds:
   ```bash
   flutter clean
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   flutter run
   ```

## MVVM Structure

### Final Directory Structure
```
lib/
├── core/                          # Core utilities
├── data/                          # Model Layer
│   ├── local/
│   ├── models/
│   └── repositories/
├── domain/                        # Business Logic
│   ├── entities/
│   └── services/                 # ✅ NEW LOCATION
├── presentation/                  # View + ViewModel Layer
│   ├── viewmodels/               # ✅ NEW LOCATION (ViewModels)
│   ├── pages/                    # Views
│   └── widgets/                  # Reusable UI components
```

### Layer Responsibilities

**Model (Data Layer)**
- Data persistence (Hive, Supabase)
- External API calls
- Data models and DTOs
- Repository implementations

**ViewModel (Presentation/ViewModels)**
- State management (Riverpod Providers)
- Presentation logic
- User interaction handling
- Data transformation for UI

**View (Presentation/Pages & Widgets)**
- UI rendering
- User input collection
- Display state from ViewModels
- Navigation

**Domain (Business Logic)**
- Core business rules
- Services and use cases
- Independent of frameworks
- Reusable logic

## Benefits of This Structure

1. **Clear Separation of Concerns**: Each layer has a specific responsibility
2. **Testability**: ViewModels can be tested independently
3. **Maintainability**: Easy to locate and modify code
4. **Scalability**: Structure supports growth
5. **Standard MVVM**: Follows industry best practices

## Migration Checklist

- [x] Move providers to presentation/viewmodels
- [x] Move services to domain/services
- [x] Create barrel export file
- [x] Update imports in viewmodels
- [x] Update imports in services
- [ ] Update imports in pages (automated)
- [ ] Update imports in widgets (automated)
- [ ] Remove old directories
- [ ] Test the application
- [ ] Update documentation

## Troubleshooting

**Issue**: Import errors after migration
**Solution**: Run `flutter clean && flutter pub get`

**Issue**: Generated files not found
**Solution**: Run `flutter pub run build_runner build --delete-conflicting-outputs`

**Issue**: Old import paths still referenced
**Solution**: Use Find & Replace in your IDE to update remaining imports

## Next Steps

1. Run the automated migration script
2. Delete old directories
3. Test the application thoroughly
4. Update any remaining manual imports
5. Commit changes to version control
