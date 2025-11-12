import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// removed google_generative_ai dependency - using Groq REST only
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:grapemaster/l10n/app_localizations.dart';
import '../../main.dart';

// Backend selection removed — this screen now always uses the Groq proxy/request flow.

class ChatbotScreen extends StatefulWidget {
  final String? initialMessage;

  const ChatbotScreen({super.key, this.initialMessage});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  // Stored messages loaded from persistence but NOT shown automatically.
  final List<ChatMessage> _storedMessages = [];
  bool _isLoading = false;
  // Diagnostics from the last Groq HTTP call (status/body) for debugging.
  String? _lastGroqDebug;
  // Groq configurable endpoint + key. Edit via the UI or store your own.
  // Groq uses OpenAI-compatible chat completion API
  String _groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';
  String _groqModel = 'llama-3.1-8b-instant';
  // Fetch API key from environment variables for security
  late String _groqApiKey;

  @override
  void initState() {
    super.initState();

    // Load API key from environment
    _groqApiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (_groqApiKey.isEmpty) {
      print('⚠️ Warning: GROQ_API_KEY not found in environment variables');
    }

    // Initialize model
    // NOTE: some Gemini model names (eg. 'gemini-pro') are not available on
    // all API versions or projects. If you see an error like
    // "models/gemini-pro is not found for API version v1beta" use
    // ListModels to see available models for your API key and replace the
    // model name below accordingly.
    // Common safe fallback: 'text-bison-001' (text generation model) — try
    // that if gemini models are not available for your account.
    // Using Groq REST backend only; no SDK model initialization required.

    // Start chat with system context
    // No SDK chat initialization needed — Groq backend will be used for all requests.

    // After startup, load saved chat config and history (backend + groq)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadChatConfig();
      if (!mounted) return;

      await _loadChatHistory();
      if (!mounted) return;

      // If no saved history, add welcome message (only when still mounted)
      if (_messages.isEmpty) {
        // Use a no-brand welcome specifically for the chat UI
        final welcome = stringsOf(context).t('chat_welcome_nobrand');
        _messages.add(
          ChatMessage(
            text: welcome,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      }

      // If initial message provided, send it automatically (guarded)
      if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _sendMessage(widget.initialMessage!, isExternalQuery: true);
        });
      }

      if (mounted) setState(() {});
    });
  }

  // Save a single message to persistence (Firestore per-user, fallback to SharedPreferences)
  Future<void> _saveMessage(ChatMessage msg) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('chatHistory')
            .doc();
        await doc.set({
          'text': msg.text,
          'isUser': msg.isUser,
          'timestamp': FieldValue.serverTimestamp(),
          'isSpecialQuery': msg.isSpecialQuery,
          'queryType': msg.queryType,
        });
        return;
      }

      // Fallback: save to SharedPreferences as JSON list
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList('chat_history') ?? [];
      final entry = json.encode({
        'text': msg.text,
        'isUser': msg.isUser,
        'timestamp': msg.timestamp.toIso8601String(),
        'isSpecialQuery': msg.isSpecialQuery,
        'queryType': msg.queryType,
      });
      raw.add(entry);
      await prefs.setStringList('chat_history', raw);
    } catch (e) {
      print('Failed to save chat message: $e');
    }
  }

  // Load chat history from Firestore if signed-in, otherwise from SharedPreferences
  Future<void> _loadChatHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('chatHistory')
            .orderBy('timestamp', descending: false)
            .get();
        _storedMessages.clear();
        for (final doc in snap.docs) {
          final data = doc.data();
          final text = (data['text'] ?? '') as String;
          final isUser = (data['isUser'] ?? false) as bool;
          final isSpecial = (data['isSpecialQuery'] ?? false) as bool;
          final queryType = (data['queryType'] ?? 'general') as String;
          DateTime ts = DateTime.now();
          try {
            final t = data['timestamp'];
            if (t is Timestamp) ts = t.toDate();
          } catch (_) {}
          _storedMessages.add(
            ChatMessage(
              text: text,
              isUser: isUser,
              timestamp: ts,
              isSpecialQuery: isSpecial,
              queryType: queryType,
            ),
          );
        }
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList('chat_history') ?? [];
      _storedMessages.clear();
      for (final s in raw) {
        try {
          final m = json.decode(s);
          final text = (m['text'] ?? '') as String;
          final isUser = (m['isUser'] ?? false) as bool;
          final isSpecial = (m['isSpecialQuery'] ?? false) as bool;
          final queryType = (m['queryType'] ?? 'general') as String;
          final tsStr =
              (m['timestamp'] ?? DateTime.now().toIso8601String()) as String;
          final ts = DateTime.tryParse(tsStr) ?? DateTime.now();
          _storedMessages.add(
            ChatMessage(
              text: text,
              isUser: isUser,
              timestamp: ts,
              isSpecialQuery: isSpecial,
              queryType: queryType,
            ),
          );
        } catch (_) {}
      }
      return;
    } catch (e) {
      print('Failed to load chat history: $e');
    }
  }

  // Replace the current visible chat with stored history
  void _loadStoredIntoChat() {
    setState(() {
      _messages.clear();
      // ensure welcome at top if stored is empty
      if (_storedMessages.isEmpty) {
        _messages.add(
          ChatMessage(text: stringsOf(context).t('chat_welcome_nobrand'), isUser: false, timestamp: DateTime.now()),
        );
      } else {
        _messages.addAll(_storedMessages);
      }
    });
    _scrollToBottom();
  }

  // Clear persisted history (Firestore or SharedPreferences)
  Future<void> _clearSavedHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final coll = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('chatHistory');
        final snap = await coll.get();
        for (final doc in snap.docs) {
          await doc.reference.delete();
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('chat_history');
      }
      _storedMessages.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(stringsOf(context).t('Chat history cleared'))));
      }
    } catch (e) {
      print('Failed to clear history: $e');
    }
  }

  Future<void> _showHistorySheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(stringsOf(context).t('Chat history'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                  ],
                ),
              ),
              Expanded(
                child: _storedMessages.isEmpty
                    ? Center(child: Text(stringsOf(context).t('No saved chats')))
                    : ListView.builder(
                        itemCount: _storedMessages.length,
                        itemBuilder: (_, i) {
                          final m = _storedMessages[i];
                          return ListTile(
                            leading: Icon(m.isUser ? Icons.person : Icons.smart_toy_outlined),
                            title: Text(m.isUser ? stringsOf(context).t('You') : stringsOf(context).t('Assistant')),
                            subtitle: Text(m.text, maxLines: 3, overflow: TextOverflow.ellipsis),
                            onTap: () {
                              // Load a single message into input for quick reuse
                              Navigator.of(ctx).pop();
                              setState(() {
                                _messages.clear();
                                _messages.addAll(_storedMessages);
                              });
                              _scrollToBottom();
                            },
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _loadStoredIntoChat();
                          Navigator.of(ctx).pop();
                        },
                        child: Text(stringsOf(context).t('Load history')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await _clearSavedHistory();
                      },
                      child: Text(stringsOf(context).t('Clear saved history')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendMessage(
    String message, {
    bool isExternalQuery = false,
  }) async {
    if (message.trim().isEmpty) return;

    // Check if this is a special query that should be styled
    // Detection queries: contains "I detected" and "confidence"
    // Crop queries: contains "crop" and multiple ** markers (formatted query)
    final isDetectionQuery =
        message.contains('I detected') && message.contains('confidence');
    final isCropQuery =
        message.contains('crop') && message.split('**').length > 4;
    final isSpecialQuery = isExternalQuery || isDetectionQuery || isCropQuery;

    // Add user message
    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
          isSpecialQuery: isSpecialQuery,
          queryType: isDetectionQuery
              ? 'disease'
              : (isCropQuery ? 'crop' : 'general'),
        ),
      );
      _isLoading = true;
    });

    // Persist the user message
    try {
      final userMsg = _messages.last;
      _saveMessage(userMsg);
    } catch (_) {}

    _messageController.clear();
    _scrollToBottom();

    try {
  // Groq-only flow: attempt Groq endpoint and show response or error.
  final groqReply = await _sendMessageViaGroq(message);
      if (groqReply != null) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: groqReply,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        // Persist assistant reply
        try {
          final assistantMsg = _messages.last;
          _saveMessage(assistantMsg);
        } catch (_) {}
        _scrollToBottom();
        return;
      }

      // If we reach here, Groq did not return a reply. Show debug info if available.
      setState(() {
        final debug = _lastGroqDebug;
        final messageText = debug == null || debug.isEmpty
            ? 'No response from Groq backend. Check endpoint/key in settings.'
            : 'No response from Groq backend. Debug: $debug';

        _messages.add(
          ChatMessage(
            text: messageText,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      // If the debug indicates an invalid API key (401), prompt the user to open settings to fix it
      try {
        final debug = _lastGroqDebug?.toLowerCase() ?? '';
        if (debug.contains('invalid_api_key') || debug.contains('401')) {
          if (context.mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Groq returned 401 — invalid API key.'),
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: () => _openGroqSettingsDialog(),
                ),
              ),
            );
        }
      } catch (_) {}
      try {
        final assistantMsg = _messages.last;
        _saveMessage(assistantMsg);
      } catch (_) {}
      _scrollToBottom();
    } catch (e) {
      print('Groq send error: $e');
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Error when calling Groq: ${e.toString()}',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      try {
        final assistantMsg = _messages.last;
        _saveMessage(assistantMsg);
      } catch (_) {}
      _scrollToBottom();
    }
  }

  // Google REST fallback removed — Groq-only configuration.

  // Groq send: POST to configured _groqEndpoint with API key.
  // Returns assistant text on success, or null on failure.
  Future<String?> _sendMessageViaGroq(String prompt) async {
    try {
      final url = Uri.parse(_groqEndpoint);
      // Groq uses OpenAI-compatible chat completion format
      // Add system message to restrict chatbot to farming topics only
      // Build system prompt localized to the selected app language and request
      // the assistant to reply in that language.
      final langCode = LocaleController.instance.locale?.languageCode ?? 'en';
      final langLabelKey = langCode == 'hi' ? 'हिन्दी' : (langCode == 'mr' ? 'मराठी' : 'English');
      final langLabel = stringsOf(context).t(langLabelKey);
      final systemBase = stringsOf(context).t('chat_system_prompt');
      final respondPhrase = stringsOf(context).t('chat_respond_in').replaceAll('{lang}', langLabel);
      final systemContent = '$systemBase\n\n$respondPhrase';

      final body = json.encode({
        'model': _groqModel,
        'messages': [
          {
            'role': 'system',
            'content': systemContent,
          },
          {'role': 'user', 'content': prompt},
        ],
      });
      // Try the two common header styles: Authorization: Bearer <key> and Api-Key: <key>
      final headersBearer = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_groqApiKey',
      };

      final headersApiKey = {
        'Content-Type': 'application/json',
        'Api-Key': _groqApiKey,
      };

      http.Response? r;

      // First try Authorization: Bearer
      try {
        r = await http
            .post(url, headers: headersBearer, body: body)
            .timeout(const Duration(seconds: 12));
        if (r.statusCode == 401 || r.statusCode == 403) {
          // Try alternate header style if auth fails
          final alt = await http
              .post(url, headers: headersApiKey, body: body)
              .timeout(const Duration(seconds: 12));
          // prefer alt if it succeeds
          if (alt.statusCode == 200) r = alt;
        }
      } catch (e) {
        // If the first attempt throws (network/timeout), fall back to trying the alternate once
        try {
          r = await http
              .post(url, headers: headersApiKey, body: body)
              .timeout(const Duration(seconds: 12));
        } catch (_) {}
      }

      if (r != null && r.statusCode == 200) {
        final decoded = json.decode(r.body);
        // Groq returns OpenAI-compatible chat completion format:
        // { "choices": [{ "message": { "content": "..." } }] }
        try {
          final choices = decoded['choices'];
          if (choices != null && choices is List && choices.isNotEmpty) {
            final message = choices[0]['message'];
            if (message != null && message is Map) {
              final content = message['content'];
              if (content != null && content is String && content.isNotEmpty) {
                return content.trim();
              }
            }
          }
        } catch (e) {
          // Fallback to heuristic extraction if format differs
          String? extract(dynamic node) {
            if (node == null) return null;
            if (node is String) return node;
            if (node is List) {
              for (var item in node) {
                final s = extract(item);
                if (s != null && s.isNotEmpty) return s;
              }
            }
            if (node is Map) {
              if (node.containsKey('content')) return extract(node['content']);
              if (node.containsKey('output')) return extract(node['output']);
              if (node.containsKey('text')) return extract(node['text']);
              if (node.containsKey('data')) return extract(node['data']);
              if (node.containsKey('result')) return extract(node['result']);
              for (var v in node.values) {
                final s = extract(v);
                if (s != null && s.isNotEmpty) return s;
              }
            }
            return null;
          }

          final text = extract(decoded);
          if (text != null) return text.trim();
        }
      } else if (r != null) {
        // Save debug info for UI visibility
        _lastGroqDebug = 'Groq POST failed: ${r.statusCode} ${r.body}';
        print(_lastGroqDebug);
      } else {
        _lastGroqDebug =
            'Groq POST failed: no response (both header styles tried)';
        print(_lastGroqDebug);
      }
    } catch (err) {
      _lastGroqDebug = 'Groq send error: $err';
      print(_lastGroqDebug);
    }
    return null;
  }

  // Persist/load chat configuration (backend + groq endpoint/key)
  Future<void> _loadChatConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final endpoint = prefs.getString('groq_endpoint');
      final key = prefs.getString('groq_key');

      // Migration: if old invalid endpoint is saved, reset to new default
      if (endpoint != null &&
          endpoint.contains('/models/your-model/generate')) {
        print('Migrating old endpoint to new format');
        await prefs.remove('groq_endpoint');
        // Use the default from _groqEndpoint
      } else if (endpoint != null && endpoint.isNotEmpty) {
        _groqEndpoint = endpoint;
      }

      if (key != null && key.isNotEmpty) _groqApiKey = key;
      setState(() {});
    } catch (err) {
      print('Failed to load chat config: $err');
    }
  }

  Future<void> _saveChatConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('groq_endpoint', _groqEndpoint);
      await prefs.setString('groq_key', _groqApiKey);
    } catch (err) {
      print('Failed to save chat config: $err');
    }
  }

  // Google model listing and selection removed — using Groq-only backend.

  Future<void> _openGroqSettingsDialog() async {
    final endpointController = TextEditingController(text: _groqEndpoint);
    final keyController = TextEditingController(text: _groqApiKey);
    // backend selection removed; always use Groq/proxy

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chat settings'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Groq endpoint and API key (the app will call this directly)',
              ),
              const SizedBox(height: 8),
              const Text('Groq endpoint'),
              TextField(controller: endpointController),
              const SizedBox(height: 8),
              const Text('Groq API key'),
              TextField(controller: keyController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Run a quick test connection using the values currently in the dialog
              final endpoint = endpointController.text.trim();
              final key = keyController.text.trim();
              final result = await _testGroqConnection(endpoint, key);
              await showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Connection test result'),
                  content: SingleChildScrollView(child: Text(result)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Test'),
          ),
          ElevatedButton(
            onPressed: () async {
              final endpoint = endpointController.text.trim();
              final key = keyController.text.trim();

              // Run a quick validation before saving
              final result = await _testGroqConnection(endpoint, key);

              // Try to extract status code from the result string
              final statusMatch = RegExp(
                r'Status:\s*(\d+)',
                caseSensitive: false,
              ).firstMatch(result ?? '');
              final statusCode = statusMatch != null
                  ? int.tryParse(statusMatch.group(1)!)
                  : null;

              if (statusCode == 200) {
                // Good — save and close
                setState(() {
                  _groqEndpoint = endpoint;
                  _groqApiKey = key;
                });
                await _saveChatConfig();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chat settings saved and validated.'),
                    ),
                  );
                }
                return;
              }

              // If not 200, show a friendly dialog with the test result and options
              if (context.mounted) {
                await showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Validation failed'),
                    content: SingleChildScrollView(child: Text(result)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Save anyway despite validation failure
                          setState(() {
                            _groqEndpoint = endpoint;
                            _groqApiKey = key;
                          });
                          _saveChatConfig();
                          Navigator.of(
                            context,
                          ).pop(); // close validation dialog
                          Navigator.of(context).pop(); // close settings dialog
                          if (context.mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Chat settings saved (validation failed)',
                                ),
                              ),
                            );
                        },
                        child: const Text('Save anyway'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Test the Groq endpoint with a lightweight ping request and return a readable result.
  Future<String> _testGroqConnection(String endpoint, String key) async {
    try {
      final url = Uri.parse(endpoint);
      // Use the same minimal chat-completion format as the real request so the server validates the key similarly
      final body = json.encode({
        'model': _groqModel,
        'messages': [
          {'role': 'user', 'content': 'ping'},
        ],
      });

      final headersBearer = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $key',
      };
      final headersApiKey = {
        'Content-Type': 'application/json',
        'Api-Key': key,
      };

      http.Response? r;
      try {
        r = await http
            .post(url, headers: headersBearer, body: body)
            .timeout(const Duration(seconds: 8));
        if (r.statusCode == 401 || r.statusCode == 403) {
          // Try alternate header style
          final alt = await http
              .post(url, headers: headersApiKey, body: body)
              .timeout(const Duration(seconds: 8));
          if (alt.statusCode == 200) {
            return 'Status: ${alt.statusCode}\nBody:\n${alt.body}\n\nNote: authentication succeeded when using header "Api-Key: <key>".';
          }
        } else if (r.statusCode == 200) {
          return 'Status: ${r.statusCode}\nBody:\n${r.body}\n\nNote: authentication succeeded with "Authorization: Bearer <key>".';
        }
      } catch (e) {
        // ignore and try alternate
      }

      // Try alternate if first didn't return 200
      try {
        final alt = await http
            .post(url, headers: headersApiKey, body: body)
            .timeout(const Duration(seconds: 8));
        if (alt.statusCode == 200)
          return 'Status: ${alt.statusCode}\nBody:\n${alt.body}\n\nNote: authentication succeeded when using header "Api-Key: <key>".';
        if (alt.statusCode != null)
          return 'Status: ${alt.statusCode}\nBody:\n${alt.body}';
      } catch (e) {
        return 'Error: ${e.toString()}';
      }

      return r != null
          ? 'Status: ${r.statusCode}\nBody:\n${r.body}'
          : 'No response from server (both header styles tried)';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D5EF9), Color(0xFF4A90E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x220D5EF9),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            title: Row(
              children: [
                const Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)?.farmingAssistant ??
                        'Farming Assistant',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: _openGroqSettingsDialog,
                tooltip:
                    AppLocalizations.of(context)?.chatSettings ??
                    'Chat settings',
              ),
              IconButton(
                icon: const Icon(Icons.history_outlined),
                onPressed: _showHistorySheet,
                tooltip: stringsOf(context).t('Chat history'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () {
                  setState(() {
                    _messages.clear();
                    _messages.add(
                      ChatMessage(
                        text: stringsOf(context).t('chat_welcome_nobrand'),
                        isUser: false,
                        timestamp: DateTime.now(),
                      ),
                    );
                  });
                },
                tooltip:
                    AppLocalizations.of(context)?.clearChatTooltip ??
                    'Clear chat',
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF0D5EF9),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context)?.assistantTyping ??
                              'Assistant is typing...',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input Area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)?.askAboutFarming ??
                              'Ask about farming...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: IconButton(
                              icon: Icon(
                                Icons.mic_outlined,
                                color: Colors.grey.shade500,
                                size: 22,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.mic,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(
                                                context,
                                              )?.voiceComingSoon ??
                                              '🎤 Voice input coming soon!',
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF0D5EF9),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        maxLines: null,
                        maxLength: 500,
                        buildCounter:
                            (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) {
                              return null; // Hide character counter
                            },
                        style: const TextStyle(fontSize: 14),
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D5EF9), Color(0xFF4A90E2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D5EF9).withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: _isLoading
                            ? null
                            : () => _sendMessage(_messageController.text),
                        child: Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          child: Icon(
                            _isLoading
                                ? Icons.hourglass_empty_rounded
                                : Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isSpecialQuery;
  final String queryType; // 'disease', 'crop', 'general'

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isSpecialQuery = false,
    this.queryType = 'general',
  });
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  // Parse detection query to extract disease name and confidence
  Map<String, String>? _parseDetectionQuery() {
    if (message.queryType != 'disease') return null;

    try {
      final text = message.text;
      // Extract disease name: "I detected [disease name] disease"
      final diseaseMatch = RegExp(r'I detected (.+?) disease').firstMatch(text);
      // Extract confidence: "with XX.X% confidence"
      final confidenceMatch = RegExp(
        r'with ([\d.]+)% confidence',
      ).firstMatch(text);

      if (diseaseMatch != null && confidenceMatch != null) {
        return {
          'disease': diseaseMatch.group(1) ?? '',
          'confidence': confidenceMatch.group(1) ?? '',
        };
      }
    } catch (e) {
      print('Error parsing detection query: $e');
    }
    return null;
  }

  // Parse crop query to extract crop name, variety, and status
  Map<String, String>? _parseCropQuery() {
    if (message.queryType != 'crop') return null;

    try {
      final text = message.text;
      // Extract crop info: "I have a [crop name] crop (Variety: [variety]) with current status: [status]"
      final cropMatch = RegExp(r'I have a (.+?) crop').firstMatch(text);
      final varietyMatch = RegExp(r'Variety: ([^)]+)').firstMatch(text);
      final statusMatch = RegExp(r'status: (\w+)').firstMatch(text);

      if (cropMatch != null) {
        return {
          'crop': cropMatch.group(1) ?? '',
          'variety': varietyMatch?.group(1) ?? 'Not specified',
          'status': statusMatch?.group(1) ?? 'Unknown',
        };
      }
    } catch (e) {
      print('Error parsing crop query: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Special rendering for disease detection queries
    if (message.queryType == 'disease' && message.isUser) {
      final parsedData = _parseDetectionQuery();

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Detection Query Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D5EF9), Color(0xFF4A90E2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D5EF9).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.biotech,
                            color: Color(0xFF0D5EF9),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Disease Detection Query',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Disease info
                  if (parsedData != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Disease name
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.coronavirus_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Detected Disease',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        parsedData['disease']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Confidence
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.analytics_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Confidence Level',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${parsedData['confidence']}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Questions preview
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.help_outline,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Requesting Information About:',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...[
                                  '• Description & Causes',
                                  '• Symptoms & Identification',
                                  '• Treatment Methods',
                                  '• Prevention Tips',
                                  '• Organic Alternatives',
                                ].map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Fallback if parsing fails
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        message.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  // Footer with timestamp
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'AI Analysis',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Special rendering for crop queries
    if (message.queryType == 'crop' && message.isUser) {
      final parsedData = _parseCropQuery();

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Crop Query Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D5EF9), Color(0xFF4A90E2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D5EF9).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.agriculture,
                            color: Color(0xFF0D5EF9),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Crop Care Consultation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Crop info
                  if (parsedData != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Crop name
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.eco_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Crop Type',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        parsedData['crop']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Variety and Status
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.category_outlined,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Variety',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        parsedData['variety']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.health_and_safety_outlined,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Status',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        parsedData['status']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Questions preview
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.help_outline,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Requesting Information About:',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...[
                                  '• General Care Tips',
                                  '• Common Diseases',
                                  '• Preventive Measures',
                                  '• Best Practices',
                                  '• Seasonal Recommendations',
                                ].map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Fallback if parsing fails
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        message.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  // Footer with timestamp
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'AI Consultation',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Regular message rendering
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D5EF9), Color(0xFF4A90E2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D5EF9).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2.5),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(
                  Icons.smart_toy_outlined,
                  size: 20,
                  color: Color(0xFF0D5EF9),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF0D5EF9), Color(0xFF4A90E2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: message.isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 5),
                  bottomRight: Radius.circular(message.isUser ? 5 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: message.isUser
                        ? const Color(0xFF0D5EF9).withOpacity(0.25)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Use markdown rendering for assistant messages
                  if (message.isUser)
                    Text(
                      message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  else
                    MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 15,
                          height: 1.6,
                        ),
                        strong: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D5EF9),
                        ),
                        em: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade700,
                        ),
                        h1: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D5EF9),
                        ),
                        h2: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D5EF9),
                        ),
                        h3: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D5EF9),
                        ),
                        listBullet: const TextStyle(
                          color: Color(0xFF0D5EF9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        listIndent: 20,
                        code: TextStyle(
                          backgroundColor: const Color(0xFFF5F7FA),
                          color: const Color(0xFF0D5EF9),
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                        blockquote: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white.withOpacity(0.75)
                          : Colors.grey.shade400,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF0D5EF9)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D5EF9).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2.5),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(
                  Icons.person_outline,
                  size: 20,
                  color: Color(0xFF0D5EF9),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
