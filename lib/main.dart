import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';
import 'data/app_data.dart';
import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';

void main() async {
  // Needed before using SharedPreferences in main().
  WidgetsFlutterBinding.ensureInitialized();

  // The app is designed for a phone held upright.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Load the saved tasks and members before the first screen is shown.
  bool loadedOk = await AppData.load();

  runApp(MyApp(loadedOk: loadedOk));
}

class MyApp extends StatelessWidget {
  final bool loadedOk;

  const MyApp({super.key, required this.loadedOk});

  @override
  Widget build(BuildContext context) {
    // If someone was signed in last time, go straight to the home screen.
    Widget firstScreen;
    if (AppData.currentUser() != null) {
      firstScreen = const HomeScreen();
    } else {
      firstScreen = SignInScreen(showDataError: !loadedOk);
    }

    return MaterialApp(
      title: 'OnTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: mainColor,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(backgroundColor: backgroundColor),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: firstScreen,
    );
  }
}
