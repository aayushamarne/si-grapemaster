import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: const Color(0xFF0D5EF9),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF0D5EF9), Colors.blue.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.privacy_tip, color: Colors.white, size: 48),
                SizedBox(height: 12),
                Text(
                  'Privacy Policy',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  'Last updated: January 2024',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Introduction
          _buildSection(
            'Introduction',
            'Welcome to GrapeMaster. We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and safeguard your information when you use our mobile application.',
          ),

          // Information We Collect
          _buildSection(
            'Information We Collect',
            '''We collect the following types of information:

1. Personal Information:
   • Name and email address (when you register)
   • Profile photo (optional)
   • Phone number (optional)

2. Usage Data:
   • App usage patterns and preferences
   • Device information (model, OS version)
   • Images uploaded for disease detection

3. Location Data:
   • Approximate location for weather updates
   • GPS data for region-specific farming tips''',
          ),

          // How We Use Your Information
          _buildSection(
            'How We Use Your Information',
            '''We use your information to:

• Provide disease detection services for your crops
• Deliver personalized farming recommendations
• Send important notifications and updates
• Improve our AI models and services
• Provide customer support
• Ensure app security and prevent fraud
• Analyze app usage to enhance user experience''',
          ),

          // Data Storage and Security
          _buildSection(
            'Data Storage and Security',
            '''Your data is stored securely using:

• Firebase Authentication for user accounts
• Encrypted cloud storage for images
• Industry-standard security protocols
• Regular security audits and updates

We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.''',
          ),

          // Data Sharing
          _buildSection(
            'Data Sharing',
            '''We do NOT sell your personal data to third parties.

We may share your information only in these cases:
• With your explicit consent
• To comply with legal obligations
• To protect our rights and safety
• With service providers (Google Cloud, Firebase) who assist in app operations

All third-party services are required to maintain data confidentiality.''',
          ),

          // Your Rights
          _buildSection(
            'Your Rights',
            '''You have the right to:

• Access your personal data
• Correct inaccurate information
• Delete your account and data
• Opt-out of notifications
• Export your data
• Withdraw consent at any time

To exercise these rights, contact us at privacy@grapemaster.com''',
          ),

          // Cookies and Tracking
          _buildSection(
            'Cookies and Tracking',
            'We use cookies and similar tracking technologies to track activity on our app and store certain information. You can control cookie preferences in your device settings.',
          ),

          // Children\'s Privacy
          _buildSection(
            'Children\'s Privacy',
            'GrapeMaster is not intended for users under 13 years of age. We do not knowingly collect personal information from children under 13. If you believe we have collected such information, please contact us immediately.',
          ),

          // Changes to Policy
          _buildSection(
            'Changes to This Policy',
            'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
          ),

          // Contact Us
          _buildSection(
            'Contact Us',
            '''If you have questions about this Privacy Policy, contact us:

Email: privacy@grapemaster.com
Phone: +91-1800-123-4567
Address: GrapeMaster Technologies, India''',
          ),

          const SizedBox(height: 24),

          // Acceptance Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'By using GrapeMaster, you agree to this Privacy Policy.',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D5EF9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
