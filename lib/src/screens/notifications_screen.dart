import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _cropUpdates = true;
  bool _diseaseAlerts = true;
  bool _weatherAlerts = true;
  bool _marketPrices = false;
  bool _communityPosts = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? false;
      _cropUpdates = prefs.getBool('crop_updates') ?? true;
      _diseaseAlerts = prefs.getBool('disease_alerts') ?? true;
      _weatherAlerts = prefs.getBool('weather_alerts') ?? true;
      _marketPrices = prefs.getBool('market_prices') ?? false;
      _communityPosts = prefs.getBool('community_posts') ?? false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Notification preferences saved'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF0D5EF9),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General Notifications
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(
                    Icons.notifications_active,
                    color: Color(0xFF0D5EF9),
                  ),
                  title: Text(
                    'General',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildSwitchTile(
                  'Push Notifications',
                  'Receive notifications on your device',
                  _pushNotifications,
                  (value) {
                    setState(() => _pushNotifications = value);
                    _savePreference('push_notifications', value);
                  },
                ),
                _buildSwitchTile(
                  'Email Notifications',
                  'Receive updates via email',
                  _emailNotifications,
                  (value) {
                    setState(() => _emailNotifications = value);
                    _savePreference('email_notifications', value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Farming Updates
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.agriculture, color: Colors.green),
                  title: Text(
                    'Farming Updates',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildSwitchTile(
                  'Crop Updates',
                  'Get updates about your crops',
                  _cropUpdates,
                  (value) {
                    setState(() => _cropUpdates = value);
                    _savePreference('crop_updates', value);
                  },
                ),
                _buildSwitchTile(
                  'Disease Alerts',
                  'Alerts for potential crop diseases',
                  _diseaseAlerts,
                  (value) {
                    setState(() => _diseaseAlerts = value);
                    _savePreference('disease_alerts', value);
                  },
                ),
                _buildSwitchTile(
                  'Weather Alerts',
                  'Important weather updates',
                  _weatherAlerts,
                  (value) {
                    setState(() => _weatherAlerts = value);
                    _savePreference('weather_alerts', value);
                  },
                ),
                _buildSwitchTile(
                  'Market Prices',
                  'Updates on crop market prices',
                  _marketPrices,
                  (value) {
                    setState(() => _marketPrices = value);
                    _savePreference('market_prices', value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Community
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.people, color: Colors.orange),
                  title: Text(
                    'Community',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildSwitchTile(
                  'Community Posts',
                  'New posts from farmers',
                  _communityPosts,
                  (value) {
                    setState(() => _communityPosts = value);
                    _savePreference('community_posts', value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'You can change these settings anytime to control what notifications you receive.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: Colors.black54),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF0D5EF9),
    );
  }
}
