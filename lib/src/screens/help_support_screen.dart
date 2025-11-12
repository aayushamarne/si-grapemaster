import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _sendEmail() async {
    const email = 'digambar.shinde@grapesmaster.com';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=GrapeMaster Support Request',
    );
    if (!await launchUrl(emailUri)) {
      throw Exception('Could not launch email');
    }
  }

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+91 7972371656');
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch phone dialer');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('Help & Support')),
        backgroundColor: const Color(0xFF0D5EF9),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Support Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.support_agent,
                          color: Color(0xFF0D5EF9),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.t('Contact Support'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.t('We\'re here to help you 24/7'),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildContactButton(
                    icon: Icons.email,
                    title: s.t('Email Support'),
                    subtitle: 'digambar.shinde@grapesmaster.com',
                    onTap: _sendEmail,
                  ),
                  const SizedBox(height: 12),
                  _buildContactButton(
                    icon: Icons.phone,
                    title: s.t('Call Us'),
                    subtitle: '+91 7972371656',
                    onTap: _makePhoneCall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // FAQ Section
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.help_outline, color: Color(0xFF0D5EF9)),
              title: Text(
                s.t('Frequently Asked Questions'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                _buildFAQItem(
                  'How do I scan for plant diseases?',
                  'Go to the home screen, tap on "Heal Your Crop" button, then use your camera to capture or upload an image of the affected plant.',
                ),
                _buildFAQItem(
                  'How accurate is the disease detection?',
                  'Our AI model has been trained on thousands of grape disease images and provides 85-95% accuracy. However, always consult with agricultural experts for critical decisions.',
                ),
                _buildFAQItem(
                  'Can I use the chatbot offline?',
                  'The AI chatbot requires an internet connection to provide real-time assistance and accurate information.',
                ),
                _buildFAQItem(
                  'How do I update my profile?',
                  'Go to the "You" tab, tap on "Profile Settings", make your changes, and tap "Save Changes".',
                ),
                _buildFAQItem(
                  'Is my data secure?',
                  'Yes, we use Firebase Authentication and encryption to protect your personal information. We never share your data with third parties without consent.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Links
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.link, color: Color(0xFF0D5EF9)),
                  title: Text(
                    s.t('Quick Links'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _buildLinkTile(
                  icon: Icons.article,
                  title: s.t('User Guide'),
                  onTap: () => _launchURL('https://grapemaster.com/guide'),
                ),
                _buildLinkTile(
                  icon: Icons.video_library,
                  title: s.t('Video Tutorials'),
                  onTap: () => _launchURL('https://youtube.com/@grapemaster'),
                ),
                _buildLinkTile(
                  icon: Icons.forum,
                  title: s.t('Community Forum'),
                  onTap: () => _launchURL('https://forum.grapemaster.com'),
                ),
                _buildLinkTile(
                  icon: Icons.bug_report,
                  title: s.t('Report a Bug'),
                  onTap: () => _showFeedbackDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // App Version Info
          Card(
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    s.t('GrapeMaster'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    s.t('Version 1.0.0'),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2024 GrapeMaster. All rights reserved.',
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0D5EF9)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title),
      trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please describe the issue you encountered:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the bug...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your feedback!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5EF9),
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
