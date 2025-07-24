import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../provider_task/weather_provider.dart';
import '../provider_task/holiday_provider.dart'; // Nuevo 24 de julio

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  void initState() {
    super.initState();
    _loadInitialWeather();
  }

  void _loadInitialWeather() {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    weatherProvider.loadWeatherByCity('Querétaro'); // Ciudad por defecto
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final weatherProvider = Provider.of<WeatherProvider>(context);

    //Acceso al provider feriados
    final holidayProvider = Provider.of<HolidayProvider>(context);
    final holidayToday = holidayProvider.todayHoliday;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.greeting,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  localizations.todayTasks,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (holidayToday != null)
                  Text(
                    '🎉 Hoy es feriado: ${holidayToday.localName}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),

                const SizedBox(height: 8),
                
                // Sección del clima
                if (weatherProvider.isLoading)
                  const Text(
                    'Cargando clima...',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                
                if (weatherProvider.errorMessage != null)
                  Text(
                    weatherProvider.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                
                if (weatherProvider.weatherData != null)
                  Row(
                    children: [
                      Image.network(
                        'https://openweathermap.org/img/wn/${weatherProvider.weatherData!.iconCode}@2x.png',
                        width: 28,
                        height: 28,
                        errorBuilder: (_, __, ___) => 
                          const Icon(Icons.cloud, size: 28, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${weatherProvider.weatherData!.temperature.toStringAsFixed(1)}°C - ${weatherProvider.weatherData!.description}',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}