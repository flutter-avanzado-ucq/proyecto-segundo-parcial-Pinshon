// services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final String description;
  final double temperature;
  final String cityName;
  final String iconCode;
  final List<Weather> weather;
  final Main main;

  WeatherData({
    required this.description,
    required this.temperature,
    required this.cityName,
    required this.iconCode,
    required this.weather,
    required this.main,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      description: json['weather'][0]['description'],
      temperature: json['main']['temp'].toDouble(),
      cityName: json['name'],
      iconCode: json['weather'][0]['icon'],
      weather: (json['weather'] as List)
          .map((w) => Weather.fromJson(w))
          .toList(),
      main: Main.fromJson(json['main']),
    );
  }
}

class Weather {
  final String description;
  final String icon;

  Weather({required this.description, required this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class Main {
  final double temp;

  Main({required this.temp});

  factory Main.fromJson(Map<String, dynamic> json) {
    return Main(
      temp: json['temp'].toDouble(),
    );
  }
}

class WeatherService {
  static const String _apiKey = '6ec6f140f1ecb199dca483203cae9530';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherData> fetchWeatherByCity(String city) async {
    final url = Uri.parse(
      '$_baseUrl?q=$city&units=metric&lang=es&appid=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error ${response.statusCode}: ${response.body}',
      );
    }
  }

  Future<WeatherData> fetchWeatherByLocation(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl?lat=$lat&lon=$lon&units=metric&lang=es&appid=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error ${response.statusCode}: ${response.body}',
      );
    }
  }
}