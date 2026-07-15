import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Allow both orientations while the splash/loading screen is shown.
  // The app locks to portrait once the main UI appears (see SplashScreen).
  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const HenYardSprintApp());
}

class HenYardSprintApp extends StatelessWidget {
  const HenYardSprintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hen Yard Sprint',
      debugShowCheckedModeBanner: false,
      theme: HenTheme.build(),
      home: const SplashScreen(),
    );
  }
}
