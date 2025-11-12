import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import '../services/weather_service.dart';

/// Quick test screen to verify API connectivity
class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _result = 'Not tested yet';
  bool _testing = false;

  // Test different endpoints
  final List<String> _endpoints = [
    'http://127.0.0.1:10000/predict',
    'http://10.0.2.2:10000/predict',
    'http://192.168.110.116:10000/predict',
  ];

  Future<void> _testEndpoint(String endpoint) async {
    setState(() {
      _testing = true;
      _result = 'Testing $endpoint...';
    });

    try {
      // Try a simple GET request first to check connectivity
      final uri = Uri.parse(endpoint.replaceAll('/predict', '/'));

      print('🔍 Testing endpoint: $endpoint');

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('Connection timeout');
            },
          );

      setState(() {
        _result =
            '✅ Connected!\n'
            'Endpoint: $endpoint\n'
            'Status: ${response.statusCode}\n'
            'This endpoint should work!';
      });
    } on SocketException catch (e) {
      setState(() {
        _result =
            '❌ Cannot connect to $endpoint\n'
            'Error: $e\n'
            'Server might not be running or wrong IP';
      });
    } on TimeoutException {
      setState(() {
        _result =
            '⏱️ Timeout connecting to $endpoint\n'
            'Server not responding';
      });
    } catch (e) {
      setState(() {
        _result = '❓ Error: $e';
      });
    } finally {
      setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test API Endpoints',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...(_endpoints.map(
              (endpoint) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: _testing ? null : () => _testEndpoint(endpoint),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text(endpoint, style: const TextStyle(fontSize: 12)),
                ),
              ),
            )),
            const SizedBox(height: 24),
            // OpenWeather quick tester
            ElevatedButton(
              onPressed: _testing
                  ? null
                  : () async {
                      setState(() {
                        _testing = true;
                        _result = 'Testing OpenWeather API key...';
                      });
                      final res = await WeatherService.testApiKey();
                      setState(() {
                        _result = 'OpenWeather test: $res';
                        _testing = false;
                      });
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Test OpenWeather API Key'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _testing
                  ? const Center(child: CircularProgressIndicator())
                  : Text(_result, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Instructions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              '1. Make sure Flask server is running (python app.py)\n'
              '2. Test each endpoint above\n'
              '3. Use the working endpoint in disease_detection_screen.dart',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
