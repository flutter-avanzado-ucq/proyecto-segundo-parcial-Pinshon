import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Importaciones de tus archivos locales
import 'screens/tarea_screen.dart';
import 'tema/tema_app.dart';
import 'provider_task/task_provider.dart';
import 'provider_task/theme_provider.dart';
import 'models/task_model.dart';
import 'services/notification_service.dart';

void main() async {
  // Asegura que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive y abre la caja de tareas
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasksBox');

  // Configura el servicio de notificaciones
  await NotificationService.initializeNotifications();
  await NotificationService.requestPermission();

  // Inicia la aplicación
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          
          // Configuración de internacionalización
          localizationsDelegates: const [
            AppLocalizations.delegate, 
            GlobalMaterialLocalizations.delegate, 
            GlobalWidgetsLocalizations.delegate, 
            GlobalCupertinoLocalizations.delegate, 
          ],
          supportedLocales: const [
            Locale('en', ''), // Inglés
            Locale('es', ''), // Español
          ],
          
          // Tema y modo oscuro
          theme: AppTheme.theme,
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          
          // Pantalla inicial con verificación de localizaciones
          home: Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context);
              
              // Muestra un indicador de traducciones no están listas
              if (localizations == null) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              // Configura el título de la app con las traducciones
              return Material(
                child: DefaultTabController(
                  length: 1,
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(localizations.appTitle),
                    ),
                    body: const TaskScreen(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}