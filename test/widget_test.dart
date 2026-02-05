import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We wrap in ProviderScope because VatsalyaApp likely relies on it (accessed via context or main)
    // Note: SplashPage calls Supabase.instance which might fail in test if not mocked. 
    // This is a basic smoke test structure.
    await tester.pumpWidget(
      const ProviderScope(
        child: VatsalyaApp(),
      ),
    );

    // Verify key elements on the SplashPage
    expect(find.text('Vatsalya'), findsOneWidget);
    expect(find.text('Nurturing Growth, Daily.'), findsOneWidget);
  });
}
