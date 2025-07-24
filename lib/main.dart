import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'provider_task/locale_provider.dart';
import 'provider_task/task_provider.dart';
import 'provider_task/theme_provider.dart';
import 'screens/tarea_screen.dart';
import 'models/task_model.dart';
import 'services/notification_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'tema/tema_app.dart';
import 'provider_task/weather_provider.dart'; // Nuevo 23 de julio

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasksBox');
  
  await NotificationService.initializeNotifications();
  await NotificationService.requestPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()), // Nuevo 23 de julio
        ChangeNotifierProvider(create: (_) => WeatherProvider()), // Nuevo 23 de julio  
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Task Manager', // Texto temporal hasta que se carguen las localizaciones
          theme: AppTheme.theme,
          darkTheme: ThemeData.dark(),
          themeMode: Provider.of<ThemeProvider>(context).isDarkMode 
              ? ThemeMode.dark 
              : ThemeMode.light,
          locale: localeProvider.locale,
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            if (localeProvider.locale != null) {
              return localeProvider.locale;
            }
            if (deviceLocale != null) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == deviceLocale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            return supportedLocales.first;
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
          ],
          home: Builder(
            builder: (context) {
              // Espera a que las localizaciones estén listas
              if (AppLocalizations.of(context) == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return const TaskScreen();
            },
          ),
        );
      },
    );
  }
}