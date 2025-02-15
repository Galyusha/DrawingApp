import 'package:drawing_app/features/draw/models/offset.dart';
import 'package:drawing_app/features/draw/models/stroke.dart';
import 'package:drawing_app/features/splash/presentation/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/draw/presentation/drawscreen.dart';
import 'features/home/presentation/homescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(OffsetCustomAdapter());
  Hive.registerAdapter(StrokeAdapter());
  await Hive.openBox<List<Stroke>>('drawings'); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paint your dreams',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: false,
      ),
      initialRoute: '/',
      routes: {
        '/' : (context) => const Splashscreen(),
        '/home' : (context) => const Homescreen(),
        '/draw' : (context) => const Drawscreen(),

      },
      //home: const Scaffold(body: Center(child: Text("Welcome to Drawing App")),),
    );
  }
}

