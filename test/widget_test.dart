import 'package:budget_for_retirement/main.dart';
import 'package:budget_for_retirement/theme/theme_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: AppWidget(),
      ),
    );

    // Wait for async config loading
    await tester.pumpAndSettle();

    // App should show some UI (chart, sliders, etc.)
    expect(find.byType(AppWidget), findsOneWidget);
  });
}
