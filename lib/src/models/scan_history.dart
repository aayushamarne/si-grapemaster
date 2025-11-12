import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Model for storing disease scan history
class ScanHistory {
  final String id;
  final String diseaseName;
  final double confidence;
  final String severity;
  final String imagePath;
  final DateTime timestamp;

  ScanHistory({
    required this.id,
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.imagePath,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'severity': severity,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    return ScanHistory(
      id: json['id'] as String,
      diseaseName: json['diseaseName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      severity: json['severity'] as String,
      imagePath: json['imagePath'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Service to manage scan history using SharedPreferences
class ScanHistoryService {
  static const String _historyKey = 'scan_history';
  static const int _maxHistoryItems = 50;

  /// Save a new scan to history
  static Future<void> saveScan(ScanHistory scan) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    // Add new scan at the beginning
    history.insert(0, scan);

    // Keep only the latest items
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    // Convert to JSON and save
    final jsonList = history.map((scan) => scan.toJson()).toList();
    await prefs.setString(_historyKey, json.encode(jsonList));
  }

  /// Get all scan history
  static Future<List<ScanHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);

    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => ScanHistory.fromJson(json)).toList();
    } catch (e) {
      print('Error loading history: $e');
      return [];
    }
  }

  /// Clear all history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Delete a specific scan
  static Future<void> deleteScan(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    history.removeWhere((scan) => scan.id == id);

    final jsonList = history.map((scan) => scan.toJson()).toList();
    await prefs.setString(_historyKey, json.encode(jsonList));
  }
}
