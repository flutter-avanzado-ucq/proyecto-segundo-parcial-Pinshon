// Importamos paquetes necesarios
import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

// Esta clase maneja el tema de la app (modo claro/oscuro)
class ThemeProvider with ChangeNotifier {
  // Variable privada para saber si está en modo oscuro
  bool _isDarkMode = false;

  // Getter público para que otros widgets puedan leer el modo actual
  bool get isDarkMode => _isDarkMode;

  // Constructor: cuando se crea, carga el tema guardado
  ThemeProvider() {
    loadTheme();
  }

  // Carga el tema guardado en las preferencias
  Future<void> loadTheme() async {
    // Pregunta al servicio de preferencias qué tema estaba guardado
    _isDarkMode = await PreferencesService.getDarkMode();
    // Avisa a los widgets que el tema puede haber cambiado
    notifyListeners();
  }

  // Cambia entre tema claro y oscuro
  void toggleTheme() async {
    // Invierte el valor actual (si era true pasa a false y viceversa)
    _isDarkMode = !_isDarkMode;
    // Guarda la nueva preferencia en el almacenamiento
    await PreferencesService.setDarkMode(_isDarkMode);
    // Avisa a toda la app que el tema cambió
    notifyListeners();
  }
}