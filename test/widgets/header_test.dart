import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Importaciones de la app
import 'package:flutter_animaciones_notificaciones/services/holiday_service.dart';
import 'package:flutter_animaciones_notificaciones/services/weather_service.dart';
import 'package:flutter_animaciones_notificaciones/widgets/header.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/holiday_provider.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/weather_provider.dart';

class MockWeatherProvider extends WeatherProvider {
  @override
  WeatherData? get weatherData => WeatherData(
        description: 'Soleado',
        temperature: 25.5,
        cityName: 'Querétaro',
        iconCode: '01d',
        weather: [Weather(description: 'Soleado', icon: '01d')],
        main: Main(temp: 25.5),
      );

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  Future<void> loadWeatherByCity(String city) async {}
}

class MockHolidayProvider extends HolidayProvider {
  @override
  Holiday? get todayHoliday => Holiday(
        localName: 'Día de prueba',
        date: DateTime.now(),
      );

  @override
  Future<void> loadHolidays({
    required String countryCode,
    int? year,
  }) async {}
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _NoNetworkHttpOverrides();
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Header muestra feriado y clima correctamente', (tester) async {
    final weatherProvider = MockWeatherProvider();
    final holidayProvider = MockHolidayProvider();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es')],
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
            ChangeNotifierProvider<HolidayProvider>.value(value: holidayProvider),
          ],
          child: Scaffold(
            body: const Header(), // Cambiado a const directamente
          ),
        ),
      ),
    );

    // Esperamos suficiente tiempo para que se complete la construcción
    await tester.pumpAndSettle();

    // Verificaciones mejoradas
    debugPrint('Contenido del árbol de widgets: ${tester.allWidgets}'); // Para diagnóstico

    // Verificación más flexible para el feriado
    expect(
      find.textContaining('prueba'), 
      findsOneWidget,
      reason: 'Debería mostrar el texto del feriado mockeado',
    );

    // Verificación para la temperatura
    expect(
      find.textContaining('25'), // Busca solo el número por si hay símbolos adicionales
      findsOneWidget,
      reason: 'Debería mostrar la temperatura mockeada',
    );

    // Verificación para la descripción del clima
    expect(
      find.textContaining('Sol'), // Busca parte del texto por si está capitalizado o con formato
      findsOneWidget,
      reason: 'Debería mostrar la descripción del clima mockeada',
    );
  });
}

class _NoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}