import 'package:firebase_core/firebase_core.dart' hide FirebaseService;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'services/firebase_service.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseService.isReady = true;
  } catch (_) {
    FirebaseService.isReady = false;
  }
  final appState = AppState();
  await appState.loadRemotePosts();
  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const GitInspoApp(),
    ),
  );
}

class GitInspoApp extends StatelessWidget {
  const GitInspoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitInspo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}