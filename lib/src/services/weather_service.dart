import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class WeatherService {
  // OpenWeather API key is read from the environment variable
  // OPENWEATHER_API_KEY. Add a local `.env` in the project root with:
  // OPENWEATHER_API_KEY=your_real_key

  /// Fetch current weather for given lat/lon. If lat/lon are null, this
  /// attempts to derive location from the public IP using ip-api.com.
  /// Returns a map with keys: description, temp, temp_min, temp_max, humidity, wind_speed
  static Future<Map<String, dynamic>?> fetchCurrentWeather({
    double? lat,
    double? lon,
  }) async {
    try {
      if (kDebugMode)
        print(
          'WeatherService: fetchCurrentWeather called (lat=$lat, lon=$lon)',
        );
      if (lat == null || lon == null) {
        // Use a simple IP-based geolocation service to get approximate coordinates
        final ipRes = await http.get(Uri.parse('http://ip-api.com/json'));
        if (kDebugMode)
          print('WeatherService: ip-api status ${ipRes.statusCode}');
        if (ipRes.statusCode == 200) {
          final ipJson = json.decode(ipRes.body);
          if (ipJson != null &&
              ipJson['lat'] != null &&
              ipJson['lon'] != null) {
            lat = (ipJson['lat'] as num).toDouble();
            lon = (ipJson['lon'] as num).toDouble();
            if (kDebugMode)
              print('WeatherService: resolved coords from IP: $lat,$lon');
          }
        }
      }

      if (lat == null || lon == null) return null;

      final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        if (kDebugMode) {
          // Do not log the actual key. Only indicate absence.
          print('WeatherService: OPENWEATHER_API_KEY missing');
        }
        return null;
      }

      final weatherUri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey',
      );
      final res = await http.get(weatherUri);
      if (kDebugMode) {
        print(
          'WeatherService: GET ${weatherUri.toString()} -> ${res.statusCode}',
        );
      }
      if (res.statusCode != 200) return null;

      final jsonBody = json.decode(res.body);
      final weatherList = jsonBody['weather'] as List?;
      final main = jsonBody['main'] ?? {};
      final wind = jsonBody['wind'] ?? {};

      return {
        'description': (weatherList != null && weatherList.isNotEmpty)
            ? (weatherList[0]['main'] ?? weatherList[0]['description'])
            : 'Clear',
        'temp': (main['temp'] as num?)?.toDouble(),
        'temp_min': (main['temp_min'] as num?)?.toDouble(),
        'temp_max': (main['temp_max'] as num?)?.toDouble(),
        'humidity': main['humidity'],
        'wind_speed': (wind['speed'] as num?)?.toDouble(),
        'raw': jsonBody,
      };
    } catch (e) {
      // Don't crash the UI on network errors
      if (kDebugMode) print('WeatherService: fetch error: $e');
      return null;
    }
  }

  /// Helper to test the configured API key by performing a small request
  /// to a known location (Delhi). Returns a user-friendly message.
  static Future<String> testApiKey() async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty)
      return 'OPENWEATHER_API_KEY is missing';
    try {
      final uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=28.6139&lon=77.2090&units=metric&appid=$apiKey',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) return 'OK — API key valid';
      return 'HTTP ${res.statusCode} — ${res.reasonPhrase ?? 'Unknown'}';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
