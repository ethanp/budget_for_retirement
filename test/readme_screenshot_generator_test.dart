import 'package:budget_for_retirement/main.dart';
import 'package:budget_for_retirement/theme/theme_notifier.dart';
import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _phoneSize = Size(390, 844);

void main() {
  setUpAll(() async {
    await ETheme.loadFontsForWidgetTests();
  });

  testWidgets('writes homescreen for README', (tester) async {
    SharedPreferences.setMockInitialValues({});
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(_phoneSize);

    try {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: AppWidget(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chart'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../screenshots/homescreen.png'),
    );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
