import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'viewmodels/todo_viewmodel.dart';
import 'views/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TodoCraftApp());
}

class TodoCraftApp extends StatelessWidget {
  const TodoCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TodoCraft 3D',
        theme: ThemeData(
          colorSchemeSeed: const Color(0xff6c4df6),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}