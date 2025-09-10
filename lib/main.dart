import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vid_editor/screens/creations.dart';
import 'package:vid_editor/screens/home.dart';
import 'package:vid_editor/screens/splash.dart';
import 'package:vid_editor/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final dir = await getApplicationDocumentsDirectory();
    await StorageService.init(baseDir: dir.path);
  } catch (e, st) {
    debugPrint('Initialization failed: $e\n$st');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vid Editor',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const VideoEditsHomePage(),
        '/creations': (context) => const CreationsPage(),
      },
    );
  }
}
