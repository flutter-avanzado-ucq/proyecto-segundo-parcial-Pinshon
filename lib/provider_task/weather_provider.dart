import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadWeatherByCity(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _weatherData = await _weatherService.fetchWeatherByCity(city);
      debugPrint('Datos del clima cargados: ${_weatherData?.cityName}');
    } catch (e) {
      _errorMessage = 'No se pudo cargar el clima: ${e.toString()}';
      debugPrint('Error al cargar clima: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWeatherByLocation(double lat, double lon) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _weatherData = await _weatherService.fetchWeatherByLocation(lat, lon);
    } catch (e) {
      _errorMessage = 'Error de ubicación: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  loadWeather(double d, double e) {}
}