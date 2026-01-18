import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/presentation/pages/resources_page.dart';
import 'package:maternal_infant_care/presentation/pages/profile_page.dart';
import 'package:maternal_infant_care/presentation/pages/reminders_page.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_provider.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_meta_provider.dart';
import 'package:maternal_infant_care/presentation/pages/pregnancy_setup_page.dart';
import 'package:maternal_infant_care/presentation/pages/toddler_setup_page.dart';
import 'package:maternal_infant_care/core/utils/notification_service.dart';

// We'll import these when we create them, for now using placeholders/existing
import 'package:maternal_infant_care/presentation/pages/pregnant_dashboard_page.dart';
import 'package:maternal_infant_care/presentation/pages/toddler_dashboard_page.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    final granted = await NotificationService.requestPermission();
    print('DEBUG: MainNavigationShell - Notification permission granted: $granted');
  }

  @override
  Widget build(BuildContext context) {
    final userMeta = ref.watch(userMetaProvider);
    print('DEBUG: MainNavigationShell - role: ${userMeta.role}, startDate: ${userMeta.startDate}');
    
    // Smart Onboarding Redirection
    if (userMeta.startDate == null) {
      if (userMeta.role == UserProfileType.pregnant) {
        return const PregnancySetupPage();
      } else if (userMeta.role == UserProfileType.toddlerParent) {
        return const ToddlerSetupPage();
      }
    }

    // Determine the dashboard based on profile type
    Widget homePage;
    if (userMeta.role == UserProfileType.pregnant) {
       homePage = const PregnantDashboardPage();
    } else {
       homePage = const ToddlerDashboardPage();
    }

    final screens = [
      homePage,
      const ResourcesPage(),
      const RemindersPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Resources',
          ),
          NavigationDestination(
            icon: Icon(Icons.alarm_outlined),
            selectedIcon: Icon(Icons.alarm),
            label: 'Reminders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
