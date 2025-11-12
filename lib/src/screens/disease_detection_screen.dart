import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/scan_history.dart';
import 'chatbot_screen.dart';
import '../../main.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _detectionResult;
  List<ScanHistory> _scanHistory = [];

  // API Configuration
  // IMPORTANT: Update IP address based on your setup!
  //
  // For Android Emulator: use '10.0.2.2' (points to host machine's localhost)
  // For Physical Device: use your computer's IP address
  //   - Run in PowerShell: ipconfig | Select-String "IPv4"
  //   - Current detected IP: 10.65.94.181
  // For iOS Simulator: use '127.0.0.1'
  //
  // Make sure your Flask server is running on port 10000!
  // IMPORTANT: Make sure there are no leading/trailing spaces in the host.
  static const String apiHost = '192.168.110.190'; // Updated IP - Change this if needed
  static const String apiPort = '10000';
  // Also keep an int version of port for Uri building
  static const int apiPortInt = 10000;

  // Build a validated Uri for the predict endpoint to avoid malformed/encoded hosts
  static Uri get apiUri => Uri(scheme: 'http', host: apiHost.trim(), port: apiPortInt, path: '/predict');

  // Keep a string representation for older usages in the UI
  static String get apiEndpoint => apiUri.toString();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await ScanHistoryService.getHistory();
    setState(() {
      _scanHistory = history;
    });
  }

  Future<void> _openCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('📷 Camera permission required')),
          );
        }
        return;
      }

      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
          _detectionResult = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📸 Photo captured! Now analyzing...'),
            ),
          );
        }
        _analyzeImage();
      }
    } catch (e) {
      print('❌ Error opening camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _openGallery() async {
    try {
      PermissionStatus status;
      if (Platform.isAndroid) {
        if (await Permission.photos.isGranted) {
          status = PermissionStatus.granted;
        } else {
          status = await Permission.photos.request();
        }
      } else {
        status = await Permission.storage.request();
      }

      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🖼️ Storage permission required')),
          );
        }
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _detectionResult = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🖼️ Image selected! Now analyzing...'),
            ),
          );
        }
        _analyzeImage();
      }
    } catch (e) {
      print('❌ Error opening gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _isAnalyzing = true);

    try {
      print('🔍 Starting image analysis...');
  print('📍 Endpoint: $apiEndpoint');
  print('📁 Image path: ${_selectedImage!.path}');

  // Create multipart request using a validated Uri
  var request = http.MultipartRequest('POST', apiUri);

      // Add image file to request
      var imageFile = await http.MultipartFile.fromPath(
        'file',
        _selectedImage!.path,
      );
      request.files.add(imageFile);

      print(
        '📎 File attached: ${imageFile.filename} (${imageFile.length} bytes)',
      );

      // Send request with timeout
      print('📤 Sending image to prediction server...');

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      print('📥 Got response stream...');
      var response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the response from app.py
        final responseData = json.decode(response.body);
        final prediction = responseData['prediction'] ?? 'Unknown';
        final isHealthy = prediction.toLowerCase() == 'healthy' || 
                         prediction.toLowerCase() == 'no disease' ||
                         prediction.toLowerCase() == 'normal';

        setState(() {
          _detectionResult = {
            'disease': prediction,
            'confidence': responseData['confidence'] ?? 0.0,
            'severity': _getSeverity(responseData['confidence'] ?? 0.0),
            'description': isHealthy 
                ? 'Your grape plant appears healthy! Keep up the good care.'
                : 'Disease detected in grape leaf.',
            'symptoms': isHealthy
                ? [
                    'No visible disease symptoms',
                    'Plant looks healthy',
                  ]
                : [
                    'Check for visible signs on leaves',
                    'Monitor plant health regularly',
                  ],
            'treatment': isHealthy
                ? [
                    'Continue regular care and monitoring',
                    'Maintain current cultivation practices',
                  ]
                : [
                    'Consult with agricultural expert',
                    'Follow recommended treatment procedures',
                  ],
            'prevention': [
              'Maintain proper vineyard hygiene',
              'Regular monitoring and inspection',
            ],
          };
        });

        // Save to history
        await _saveToHistory();

        // Fetch AI-generated treatment and prevention in background (only for diseases)
        if (!isHealthy) {
          _fetchAIRecommendations();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✅ Analysis complete! Fetching AI recommendations...',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('❌ Server error - Status: ${response.statusCode}');
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print('❌ Network error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔌 Network Error - Cannot reach server',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Endpoint: $apiEndpoint'),
                const SizedBox(height: 8),
                const Text('Troubleshooting:'),
                const Text('1. Is Flask server running on port 10000?'),
                const Text('2. Is your IP correct? (Current: $apiHost)'),
                const Text('3. Run: ipconfig | Select-String "IPv4"'),
                const Text('4. For emulator, use 10.0.2.2'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } on TimeoutException catch (e) {
      print('❌ Timeout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request timeout - Server took too long'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('❌ Error analyzing image: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  String _localizedDiseaseLabel(BuildContext context, String raw) {
    try {
      final s = stringsOf(context);
      // normalize raw key to a safe translation key: powdery_mildew -> disease_powdery_mildew
      var normalized = raw.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), '_');
      normalized = normalized.replaceAll(RegExp(r'_+'), '_').trim();
      if (normalized.startsWith('_')) normalized = normalized.substring(1);
      if (normalized.endsWith('_')) normalized = normalized.substring(0, normalized.length - 1);

      final transKey = 'disease_' + normalized; // e.g. disease_powdery_mildew
      final translated = s.t(transKey);
      // If translation returns same key (not translated), fall back to cleaned title-case
      if (translated != transKey && translated.isNotEmpty) {
        return translated;
      }

      // Clean up raw string: replace underscores with spaces and title-case words
      final cleaned = raw.replaceAll('_', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      return cleaned
          .split(' ')
          .map((w) => w.isEmpty ? '' : (w[0].toUpperCase() + w.substring(1).toLowerCase()))
          .join(' ');
    } catch (e) {
      // fallback: simply replace underscores
      return raw.replaceAll('_', ' ');
    }
  }

  String _getSeverity(double confidence) {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.6) return 'Moderate';
    return 'Low';
  }

  Future<void> _saveToHistory() async {
    if (_detectionResult == null || _selectedImage == null) return;

    final scan = ScanHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      diseaseName: _detectionResult!['disease'],
      confidence: _detectionResult!['confidence'],
      severity: _detectionResult!['severity'],
      imagePath: _selectedImage!.path,
      timestamp: DateTime.now(),
    );

    await ScanHistoryService.saveScan(scan);
    await _loadHistory();
  }

  Future<void> _fetchAIRecommendations() async {
    if (_detectionResult == null) return;

    final diseaseName = _detectionResult!['disease'];
    
    // Skip AI recommendations for healthy plants
    if (diseaseName.toLowerCase() == 'healthy' || 
        diseaseName.toLowerCase() == 'no disease' ||
        diseaseName.toLowerCase() == 'normal') {
      print('✅ Plant is healthy, skipping AI recommendations');
      return;
    }
    
    final groqApiKey = dotenv.env['GROQ_API_KEY'] ?? '';

    if (groqApiKey.isEmpty) {
      print('⚠️ Groq API key not found, skipping AI recommendations');
      return;
    }

    try {
      final prompt =
          """Provide concise treatment and prevention for $diseaseName in grape plants.

Format your response EXACTLY as:
DESCRIPTION: [2 sentences about the disease]

SYMPTOMS:
- [symptom 1]
- [symptom 2]
- [symptom 3]

TREATMENT:
- [treatment 1]
- [treatment 2]
- [treatment 3]

PREVENTION:
- [prevention 1]
- [prevention 2]
- [prevention 3]

Keep each point brief and practical.""";

      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $groqApiKey',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'model': 'llama-3.1-8b-instant',
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are an expert agricultural advisor specializing in grape diseases.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.7,
              'max_tokens': 500,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;

        // Parse AI response
        final parsedData = _parseAIResponse(aiResponse);

        // Update detection result with AI data
        if (mounted) {
          setState(() {
            _detectionResult = {
              ..._detectionResult!,
              'description':
                  parsedData['description'] ?? _detectionResult!['description'],
              'symptoms':
                  parsedData['symptoms'] ?? _detectionResult!['symptoms'],
              'treatment':
                  parsedData['treatment'] ?? _detectionResult!['treatment'],
              'prevention':
                  parsedData['prevention'] ?? _detectionResult!['prevention'],
            };
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✨ AI recommendations loaded!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('⚠️ Error fetching AI recommendations: $e');
      // Fail silently - we already have basic info
    }
  }

  Map<String, dynamic> _parseAIResponse(String aiResponse) {
    final result = <String, dynamic>{};

    try {
      // Extract description
      final descMatch = RegExp(
        r'DESCRIPTION:\s*(.+?)(?=\n\n|\nSYMPTOMS:)',
        dotAll: true,
      ).firstMatch(aiResponse);
      if (descMatch != null) {
        result['description'] = descMatch.group(1)?.trim();
      }

      // Extract symptoms
      final symptomsMatch = RegExp(
        r'SYMPTOMS:\s*\n((?:- .+\n?)+)',
        multiLine: true,
      ).firstMatch(aiResponse);
      if (symptomsMatch != null) {
        final symptoms = symptomsMatch
            .group(1)
            ?.split('\n')
            .where((line) => line.trim().startsWith('-'))
            .map((line) => line.trim().substring(2).trim())
            .where((line) => line.isNotEmpty)
            .toList();
        if (symptoms != null && symptoms.isNotEmpty) {
          result['symptoms'] = symptoms;
        }
      }

      // Extract treatment
      final treatmentMatch = RegExp(
        r'TREATMENT:\s*\n((?:- .+\n?)+)',
        multiLine: true,
      ).firstMatch(aiResponse);
      if (treatmentMatch != null) {
        final treatment = treatmentMatch
            .group(1)
            ?.split('\n')
            .where((line) => line.trim().startsWith('-'))
            .map((line) => line.trim().substring(2).trim())
            .where((line) => line.isNotEmpty)
            .toList();
        if (treatment != null && treatment.isNotEmpty) {
          result['treatment'] = treatment;
        }
      }

      // Extract prevention
      final preventionMatch = RegExp(
        r'PREVENTION:\s*\n((?:- .+\n?)+)',
        multiLine: true,
      ).firstMatch(aiResponse);
      if (preventionMatch != null) {
        final prevention = preventionMatch
            .group(1)
            ?.split('\n')
            .where((line) => line.trim().startsWith('-'))
            .map((line) => line.trim().substring(2).trim())
            .where((line) => line.isNotEmpty)
            .toList();
        if (prevention != null && prevention.isNotEmpty) {
          result['prevention'] = prevention;
        }
      }
    } catch (e) {
      print('Error parsing AI response: $e');
    }

    return result;
  }

  void _askAIAboutDisease() {
    if (_detectionResult == null) return;

    final diseaseName = _detectionResult!['disease'];

    // Create comprehensive query about the disease
    final query =
        """I detected $diseaseName disease in my grape plants with ${(_detectionResult!['confidence'] * 100).toStringAsFixed(1)}% confidence.

Please provide me with:

1. **What is $diseaseName?** - Brief description of this disease
2. **What causes it?** - Main causes and conditions that lead to this disease
3. **How to identify it?** - Key symptoms and signs to look for
4. **Treatment methods** - Detailed treatment procedures and recommended fungicides/pesticides
5. **Prevention tips** - How to prevent this disease from occurring or spreading
6. **Organic alternatives** - Natural/organic treatment options if available

Please be specific and practical for grape farming.""";

    // Navigate to chatbot with pre-filled query that will auto-send
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatbotScreen(initialMessage: query),
      ),
    );
  }

  void _showHistoryDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Scan History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_scanHistory.isNotEmpty)
                      TextButton.icon(
                        onPressed: () async {
                          await ScanHistoryService.clearHistory();
                          await _loadHistory();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('History cleared')),
                          );
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Clear All'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _scanHistory.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No scan history yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _scanHistory.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final scan = _scanHistory[index];
                          return _buildHistoryCard(scan);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ScanHistory scan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(scan.imagePath),
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              );
            },
          ),
        ),
        title: Text(
          _localizedDiseaseLabel(context, scan.diseaseName),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${stringsOf(context).t('Confidence')}: ${(scan.confidence * 100).toStringAsFixed(1)}% • ${stringsOf(context).t('Severity')}: ${scan.severity}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTimestamp(scan.timestamp),
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () async {
            await ScanHistoryService.deleteScan(scan.id);
            await _loadHistory();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Scan deleted')));
          },
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF0D5EF9)),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _openCamera();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF0D5EF9),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _openGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.grey),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
      case 'mild':
        return Colors.green;
      case 'moderate':
      case 'medium':
        return Colors.orange;
      case 'high':
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Disease Detection'),
        backgroundColor: const Color(0xFF0D5EF9),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.history),
                if (_scanHistory.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_scanHistory.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showHistoryDialog,
            tooltip: 'Scan History',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section with Steps
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Heal your crop',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Process Steps
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProcessStep(
                        Icons.camera_alt,
                        'Take a\npicture',
                        const Color(0xFF0D5EF9),
                      ),
                      _buildArrow(),
                      _buildProcessStep(
                        Icons.description,
                        'See\ndiagnosis',
                        const Color(0xFF0D5EF9),
                      ),
                      _buildArrow(),
                      _buildProcessStep(
                        Icons.local_hospital,
                        'Get\nmedicine',
                        const Color(0xFF0D5EF9),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Take Picture Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAnalyzing ? null : _showImageSourceDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D5EF9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Take a picture',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Selected Image Preview
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImage!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],

            // Loading Indicator
            if (_isAnalyzing) ...[
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF0D5EF9),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '🔬 Analyzing your plant...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This may take a few seconds',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],

            // Detection Results
            if (_detectionResult != null) ...[
              const SizedBox(height: 24),

              // Disease Card
              Builder(
                builder: (context) {
                  final diseaseName = _detectionResult!['disease'];
                  final isHealthy = diseaseName.toLowerCase() == 'healthy' || 
                                   diseaseName.toLowerCase() == 'no disease' ||
                                   diseaseName.toLowerCase() == 'normal';
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isHealthy 
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : [Colors.red.shade400, Colors.red.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isHealthy ? Colors.green : Colors.red).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isHealthy ? Icons.check_circle : Icons.coronavirus,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isHealthy 
                                          ? stringsOf(context).t('Plant Status')
                                          : stringsOf(context).t('Detected Disease'),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _localizedDiseaseLabel(context, diseaseName),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (!isHealthy) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                _buildStatChip(
                                  '${(_detectionResult!['confidence'] * 100).toStringAsFixed(0)}%',
                                  stringsOf(context).t('Confidence'),
                                ),
                                const SizedBox(width: 12),
                                _buildStatChip(
                                  _detectionResult!['severity'],
                                  stringsOf(context).t('Severity'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Description Card
              _buildDetailCard(
                'Description',
                Icons.info_outline,
                _detectionResult!['description'],
                Colors.blue,
              ),

              // Symptoms Card
              _buildListCard(
                'Symptoms',
                Icons.healing,
                _detectionResult!['symptoms'],
                Colors.orange,
              ),

              // Treatment Card
              _buildListCard(
                'Treatment',
                Icons.medication,
                _detectionResult!['treatment'],
                Colors.green,
              ),

              // Prevention Card
              _buildListCard(
                'Prevention',
                Icons.shield,
                _detectionResult!['prevention'],
                Colors.purple,
              ),

              const SizedBox(height: 16),

              // Ask AI Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _askAIAboutDisease,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text(
                    'Ask AI about this disease',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D5EF9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessStep(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, size: 40, color: color),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildArrow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Icon(Icons.arrow_forward, color: Colors.grey.shade400, size: 28),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    String title,
    IconData icon,
    String content,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(
    String title,
    IconData icon,
    List<dynamic> items,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
