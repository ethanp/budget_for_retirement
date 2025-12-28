import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/financial_simulation.dart';
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart';
import 'util/config_loader.dart';
import 'widgets/config_error_screen.dart';
import 'widgets/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: AppWidget(),
    ),
  );
}

class AppWidget extends StatelessWidget {
  AppWidget({ConfigLoader? loader}) : _loader = loader ?? ConfigLoader();

  final ConfigLoader _loader;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return FutureBuilder<Map<String, dynamic>>(
      future: _loader.load(),
      builder: (context, snapshot) {
        Widget home;
        if (snapshot.connectionState != ConnectionState.done) {
          home = const _LoadingScreen();
        } else if (snapshot.hasError) {
          home = ConfigErrorScreen(
            errorMessage: snapshot.error.toString(),
          );
        } else {
          final configJson = snapshot.requireData;
          home = ChangeNotifierProvider(
            create: (_) => FinancialSimulation(configJson: configJson),
            child: HomePage(),
          );
        }

        return MaterialApp(
          title: 'Retirement Planner',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeNotifier.themeMode,
          home: home,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
