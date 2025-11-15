import 'package:flutter/material.dart';
import 'routes.dart';
import 'rive_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Precargar ANTES de abrir la app
  await RiveCache.precargarMascotaCalendario();
  await RiveCache.precargarMascotaPopup();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: Routes.getRoutes(),
    );
  }
}
