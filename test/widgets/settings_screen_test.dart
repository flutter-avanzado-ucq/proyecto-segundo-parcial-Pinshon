import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_animaciones_notificaciones/screens/settings_screen.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/locale_provider.dart';

void main() {
  // PRUEBA 1: Renderizado básico
  testWidgets('SettingsScreen muestra opciones de idioma', (WidgetTester tester) async {
    // Configuración del entorno de prueba
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          // Proveedor para manejo de idioma
          ChangeNotifierProvider<LocaleProvider>(
            create: (_) => LocaleProvider(),
          ),
        ],
        child: const MaterialApp(
          // Configuración de internacionalización
          localizationsDelegates: [
            AppLocalizations.delegate,       // Traducciones de la app
            GlobalMaterialLocalizations.delegate,  // Material Design localizado
            GlobalWidgetsLocalizations.delegate,   // Widgets básicos localizados
            GlobalCupertinoLocalizations.delegate, // Estilo iOS localizado
          ],
          supportedLocales: [
            Locale('es'), // Español
            Locale('en'), // Inglés
          ],
          home: Scaffold(
            body: SettingsScreen(), // Widget bajo prueba
          ),
        ),
      ),
    );

    // Espera a que se complete la construcción del widget
    await tester.pumpAndSettle();

    // VALIDACIONES PRINCIPALES
    // 1. Verificación de opciones de idioma
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Usar idioma del sistema'), findsOneWidget);

    // 2. Verificación estructural
    expect(find.byType(AppBar), findsOneWidget);
  });

  // PRUEBA 2: Interacción con opciones (NUEVA)
  testWidgets('Cambia idioma al seleccionar opción', (tester) async {
    // Configuración idéntica a la prueba anterior
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LocaleProvider>(
            create: (_) => LocaleProvider(),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('es'),
            Locale('en'),
          ],
          home: Scaffold(
            body: SettingsScreen(),
          ),
        ),
      ),
    ); // Misma configuración

    await tester.pumpAndSettle();

    // Interacción: Seleccionar inglés
    await tester.tap(find.text('English'));
    await tester.pump(); // Procesa el cambio

    // Verificación del estado
    final BuildContext context = tester.element(find.byType(SettingsScreen));
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    expect(localeProvider.locale, const Locale('en'));
  });
}