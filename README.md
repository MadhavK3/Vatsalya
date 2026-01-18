# Vatsalya - Maternal & Infant Care Mobile Application

> A comprehensive Flutter application for maternal and infant care tracking, built with Clean MVVM Architecture and modern development practices.

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## 📱 Overview

Vatsalya is a production-ready mobile application designed to support parents through pregnancy and early childhood. It provides comprehensive tracking, guidance, and AI-powered assistance for maternal and infant care.

## ✨ Features

### 🤰 Pre-Birth Care & Pregnancy Tracking
- **Month-wise Pregnancy Tracking**: Detailed tracking from month 1-9 with interactive timeline
- **Smart Checklists**: Auto-generated monthly checklists for medical tests, nutrition, and lifestyle
- **Contraction Timer**: Track and analyze labor contractions
- **Kick Counter**: Monitor baby's movements during pregnancy
- **Risk Awareness**: High-risk symptom alerts and emergency indicators
- **Pregnancy Journals**: Document your journey with notes and milestones

### 👶 Post-Delivery Infant Care
- **Feeding Tracker**: Log breastfeeding, formula, and solid food with time and quantity
- **Sleep Tracker**: Track sleep patterns with detailed duration and quality analysis
- **Diaper Tracker**: Monitor diaper changes for health insights
- **Growth Milestones**: Track weight, height, and head circumference with age-based milestones
- **Development Tracker**: Monitor developmental milestones by age

### 💉 Vaccination & Medical Records
- **Indian Vaccination Schedule**: Built-in complete vaccination schedule
- **Smart Reminders**: Auto-generated reminders before vaccination dates
- **Digital Records**: Secure storage of vaccine records and medical history
- **Export Capabilities**: Export medical records as PDF

### 📊 Analytics & Insights
- **Daily Summary**: Consolidated view of daily activities
- **Weekly Stats**: Visualize trends with interactive charts
- **Pattern Recognition**: AI-powered insights into baby's routines
- **Smart Reminders**: Context-aware reminders based on your patterns

### 🤖 AI-Powered Features
- **CareFlow AI**: Chat with AI for pregnancy and parenting advice
- **Context-Aware Responses**: Personalized responses based on your profile
- **Chat History**: Maintain conversation history across sessions
- **Safe Guidance**: Built-in safety guidelines to prevent unreliable information

### 📚 Resource Hub
- **Articles & Guides**: Curated content for various pregnancy and parenting topics
- **Activity Ideas**: Age-appropriate activity suggestions
- **Nutrition Guidance**: Dietary recommendations for pregnancy and infancy
- **Disease Awareness**: Information on common childhood illnesses

## 🏗️ Architecture

This project follows **MVVM (Model-View-ViewModel)** architecture with Clean Architecture principles:

```
lib/
├── core/                          # Core utilities and configurations
│   ├── constants/                # App-wide constants and environment variables
│   ├── theme/                    # Material 3 theme configuration
│   └── utils/                    # Utility classes (notifications, services)
│
├── data/                          # Data Layer (Model in MVVM)
│   ├── local/                    # Local storage (Hive adapters)
│   ├── models/                   # Data models with serialization
│   └── repositories/             # Repository implementations
│
├── domain/                        # Business Logic Layer
│   ├── entities/                 # Business entities (future use)
│   └── services/                 # Business logic services
│       ├── auth_service.dart
│       ├── gemini_service.dart
│       └── smart_reminder_engine.dart
│
└── presentation/                  # Presentation Layer (View + ViewModel in MVVM)
    ├── viewmodels/               # ViewModels (Riverpod Providers)
    │   ├── ai_provider.dart
    │   ├── auth_provider.dart
    │   ├── repository_providers.dart
    │   ├── smart_reminder_provider.dart
    │   ├── user_meta_provider.dart
    │   ├── user_provider.dart
    │   └── viewmodels.dart       # Barrel export file
    │
    ├── pages/                    # Screen pages (Views)
    │   ├── auth_page.dart
    │   ├── dashboard_page.dart
    │   ├── pregnancy_tracking_page.dart
    │   ├── feeding_tracking_page.dart
    │   └── ... (31 pages total)
    │
    └── widgets/                  # Reusable UI components
        ├── customizable_dashboard.dart
        ├── progress_chart.dart
        └── ... (13 widgets total)
```

### MVVM Layers Explained

#### 📦 Model (Data Layer)
- **Location**: `lib/data/`
- **Purpose**: Handles data operations, storage, and external APIs
- **Components**:
  - **Models**: Data classes with Hive annotations for local storage
  - **Repositories**: Data access logic and CRUD operations
  - **Local Storage**: Hive database adapters

#### 🎨 View (Presentation Layer - UI)
- **Location**: `lib/presentation/pages/` and `lib/presentation/widgets/`
- **Purpose**: UI rendering and user interaction
- **Components**:
  - **Pages**: Full-screen views
  - **Widgets**: Reusable UI components
- **Key Principles**:
  - No business logic
  - Observes ViewModel state
  - Handles user input

#### 🎯 ViewModel (Presentation Layer - State)
- **Location**: `lib/presentation/viewmodels/`
- **Purpose**: State management and presentation logic
- **Implementation**: Riverpod Providers
- **Responsibilities**:
  - Manage UI state
  - Handle user interactions
  - Coordinate with services/repositories
  - Provide data to Views

#### 🔧 Domain (Business Logic)
- **Location**: `lib/domain/services/`
- **Purpose**: Core business logic and rules
- **Services**:
  - **AuthService**: Authentication logic
  - **GeminiService**: AI integration
  - **SmartReminderEngine**: Intelligent reminder generation

## 🛠️ Tech Stack

### Core
- **Flutter**: 3.0+ (Latest stable)
- **Dart**: 3.0+

### State Management
- **flutter_riverpod**: 2.4.9 - Modern state management
- **riverpod_annotation**: 2.3.3 - Code generation for providers

### Local Storage
- **hive**: 2.2.3 - Fast, lightweight NoSQL database
- **hive_flutter**: 1.1.0 - Flutter integration
- **shared_preferences**: 2.2.2 - Simple key-value storage

### Backend & AI
- **supabase_flutter**: 2.3.0 - Backend as a service
- **google_generative_ai**: 0.4.0 - Gemini AI integration
- **flutter_dotenv**: 5.1.0 - Environment variable management

### UI & Animations
- **google_fonts**: 6.1.0 - Beautiful typography
- **fl_chart**: 0.66.0 - Interactive charts
- **lottie**: 3.0.0 - Smooth animations
- **flutter_staggered_grid_view**: 0.7.0 - Advanced grid layouts
- **flutter_markdown**: 0.7.7+1 - Markdown rendering

### Notifications
- **flutter_local_notifications**: 17.2.4 - Local notifications
- **timezone**: 0.9.2 - Timezone support

### Utilities
- **intl**: 0.19.0 - Internationalization
- **path_provider**: 2.1.1 - File system paths
- **pdf**: 3.10.7 - PDF generation
- **printing**: 5.12.0 - Printing support

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd project-carefree
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   
   Create a `.env` file in the root directory:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GEMINI_API_KEY=your_gemini_api_key
   ```

4. **Generate code (Hive adapters, Riverpod)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### iOS (macOS only)
```bash
flutter build ios --release
```

## 📝 Configuration

### Supabase Setup
1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Create a `profiles` table with the following schema:
   ```sql
   CREATE TABLE profiles (
     id UUID REFERENCES auth.users PRIMARY KEY,
     email TEXT UNIQUE NOT NULL,
     role TEXT,
     start_date TIMESTAMP,
     created_at TIMESTAMP DEFAULT NOW()
   );
   ```
3. Add your Supabase URL and anon key to `.env`

### Gemini AI Setup
1. Get an API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Add your API key to `.env`

## 🎯 Usage

### For Pregnant Users
1. **Onboarding**: Select "Pregnant" profile type
2. **Setup**: Enter your conception or due date
3. **Track**: Monitor your pregnancy journey month by month
4. **Chat**: Get AI-powered pregnancy advice

### For Parents
1. **Onboarding**: Select "Parent" profile type
2. **Setup**: Enter your child's date of birth
3. **Log Activities**: Track feeding, sleep, and diaper changes
4. **Monitor Growth**: Record developmental milestones
5. **Vaccinations**: Stay on top of vaccination schedules

## 🔒 Privacy & Security

- ✅ All sensitive data stored locally using Hive
- ✅ User authentication handled by Supabase
- ✅ Environment variables for API keys
- ✅ No tracking or analytics (privacy-first)
- ✅ Data export capabilities for user control

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📱 Features Status

| Feature | Status |
|---------|--------|
| MVVM Architecture | ✅ Complete |
| Authentication | ✅ Complete |
| Pregnancy Tracking | ✅ Complete |
| Feeding Tracker | ✅ Complete |
| Sleep Tracker | ✅ Complete |
| Diaper Tracker | ✅ Complete |
| Growth & Milestones | ✅ Complete |
| Vaccinations | ✅ Complete |
| AI Chat | ✅ Complete |
| Smart Reminders | ✅ Complete |
| Resource Hub | ✅ Complete |
| Dark Mode | ✅ Complete |
| PDF Export | ✅ Complete |
| Multi-language | 🔄 In Progress |
| Cloud Sync | 🔄 In Progress |

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Om Bharambe**

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for backend infrastructure
- Google for Gemini AI
- All contributors and testers

## 📞 Support

For questions or issues:
- Open an issue on GitHub
- Contact: om29dev@example.com

---

**Made with ❤️ for parents and parents-to-be**
