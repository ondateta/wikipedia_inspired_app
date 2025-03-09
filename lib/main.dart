import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:template/router.dart';
import 'package:template/src/design_system/app_theme.dart';
import 'package:template/src/services/local_storage_service.dart';
import 'package:template/src/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('appSettings');
  await Hive.openBox('userData');
  await Hive.openBox('pages');
  await Hive.openBox('comments');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      debugShowFloatingThemeButton: true,
      initial: AdaptiveThemeMode.system,
      light: AppTheme.getLightTheme(),
      dark: AppTheme.getDarkTheme(),
      builder: (lightTheme, darkTheme) {
        return MaterialApp.router(
          title: 'Local Wikipedia',
          theme: lightTheme,
          darkTheme: darkTheme,
          routerConfig: router,
          builder: (context, child) => GateWay(
            child: child ?? SplashView(),
          ),
        );
      },
    );
  }
}

class GateWay extends StatefulWidget {
  const GateWay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<GateWay> createState() => _GateWayState();
}

class _GateWayState extends State<GateWay> {
  final LocalStorageService _storageService = LocalStorageService();
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    final isLoggedIn = await _storageService.isUserLoggedIn();
    setState(() {
      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You have pushed the button this many times:',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              '$_counter',
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}