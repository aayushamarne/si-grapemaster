import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'disease_detection_screen.dart';
import 'chatbot_screen.dart';

class CropDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> crop;

  const CropDetailsScreen({super.key, required this.crop});

  Color _parseColor(dynamic colorValue) {
    if (colorValue == null) return Colors.green;

    if (colorValue is String) {
      // Handle color names
      switch (colorValue.toLowerCase()) {
        case 'green':
          return Colors.green;
        case 'blue':
          return Colors.blue;
        case 'red':
          return Colors.red;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        case 'brown':
          return Colors.brown;
        default:
          // Try to parse as hex or number string
          try {
            return Color(int.parse(colorValue));
          } catch (e) {
            return Colors.green; // Default fallback
          }
      }
    } else if (colorValue is int) {
      return Color(colorValue);
    }

    return Colors.green; // Default fallback
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _parseColor(crop['color']);

    return Scaffold(
      appBar: AppBar(
        title: Text('${crop['emoji']} ${crop['name']}'),
        backgroundColor: borderColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteCrop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Icon Card
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    crop['emoji'],
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Crop Info Cards
            _buildInfoCard('Basic Information', Icons.info_outline, [
              _InfoRow('Crop Name', crop['name']),
              if (crop['variety']?.isNotEmpty ?? false)
                _InfoRow('Variety', crop['variety']),
              _InfoRow('Area', '${crop['area']} acres'),
              _InfoRow('Planting Date', crop['plantingDate']),
            ], borderColor),

            const SizedBox(height: 16),

            _buildInfoCard('Health Status', Icons.health_and_safety_outlined, [
              _InfoRow('Status', 'Healthy', valueColor: Colors.green),
              _InfoRow('Last Check', '2 days ago'),
              _InfoRow('Next Inspection', 'In 5 days'),
            ], borderColor),

            const SizedBox(height: 16),

            _buildInfoCard('Care Schedule', Icons.calendar_today_outlined, [
              _InfoRow('Next Watering', 'Tomorrow', valueColor: Colors.blue),
              _InfoRow(
                'Fertilizer Due',
                'Next week',
                valueColor: Colors.orange,
              ),
              _InfoRow('Pest Check', 'In 3 days'),
            ], borderColor),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to disease detection screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DiseaseDetectionScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bug_report_outlined),
                    label: const Text('Check Disease'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: borderColor, width: 2),
                      foregroundColor: borderColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to AI assistant with crop context
                      final cropName = crop['name'] ?? 'Unknown';
                      final variety = crop['variety'] ?? 'Not specified';
                      final status = crop['status'] ?? 'Unknown';

                      final contextMessage =
                          '''I have a $cropName crop (Variety: $variety) with current status: $status.

Can you provide me with:

1. **General care tips** for $cropName
2. **Common diseases** that affect this crop
3. **Preventive measures** I should take
4. **Best practices** for healthy growth
5. **Seasonal recommendations** for care

Please provide specific and practical advice for grape farming.''';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatbotScreen(initialMessage: contextMessage),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Ask AI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: borderColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    IconData icon,
    List<Widget> children,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  void _deleteCrop(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Crop'),
        content: Text(
          'Are you sure you want to remove ${crop['emoji']} ${crop['name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('quickCrops')
                    .doc(crop['id'])
                    .delete();

                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close details screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🗑️ Crop removed')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
