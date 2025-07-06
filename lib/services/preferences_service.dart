// Importamos Hive para guardar cosas en el dispositivo
import 'package:hive/hive.dart';

// Esta clase es como el "memorión" de la app, guarda tus preferencias
class PreferencesService {
  // Nombre de la cajita donde guardamos todo (como una gaveta virtual)
  static const String _boxName = 'preferences_box';
  
  // La llave para guardar/leer el tema (como una etiqueta)
  static const String _themeKey = 'isDarkMode';

  // Método para guardar si quieres modo oscuro o no
  static Future<void> setDarkMode(bool isDark) async {
    // Abrimos la cajita (si no existe, la crea)
    final box = await Hive.openBox(_boxName);
    
    // Guardamos el valor como si fuera un archivo en una gaveta:
    // ("isDarkMode" = true/false)
    await box.put(_themeKey, isDark);
  }

  // Método para preguntar qué tema tenías guardado
  static Future<bool> getDarkMode() async {
    // Abrimos la misma cajita
    final box = await Hive.openBox(_boxName);
    
    // Buscamos el valor guardado, si no encuentra nada devuelve false (modo claro por defecto)
    return box.get(_themeKey, defaultValue: false);
  }
}