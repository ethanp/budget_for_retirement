import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/financial_simulation.dart';
import 'util/config_loader.dart';
import 'widgets/config_error_screen.dart';
import 'widgets/home_page.dart';

const double _MinWidth = 1370;
const double _MinHeight = 834;
const _MinReasonableSize = Size(_MinWidth, _MinHeight);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // So far, it doesn't seem to work to call this *after* calling runApp() :(
  if (Platform.isMacOS) await DesktopWindow.setWindowSize(_MinReasonableSize);

  runApp(AppWidget());
}

class AppWidget extends StatelessWidget {
  AppWidget({ConfigLoader? loader}) : _loader = loader ?? ConfigLoader();

  final ConfigLoader _loader;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SimulationDefaults>(
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
          final defaults = snapshot.requireData;
          home = MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => FinancialSimulation(defaults: defaults),
              ),
            ],
            child: HomePage(),
          );
        }

        return MaterialApp(
          title: 'Finances Simulator',
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
