import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// removed google_generative_ai dependency - using Groq REST only
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Backend selection removed — this screen now always uses the Groq proxy/request flow.

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
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
    
    // Add welcome message
    _messages.add(ChatMessage(
      text: 'Hello! 👋 I\'m your farming assistant. Ask me anything about:\n\n'
          '• Grape farming & diseases\n'
          '• Pest management\n'
          '• Irrigation tips\n'
          '• Fertilizer recommendations\n'
          '• Weather-based advice\n\n'
          'How can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    // After startup, load saved chat config (backend + groq)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatConfig();
    });
  }

  Future<void> _autoSelectModelIfNeeded() async {
    // No-op: Google model auto-selection removed for Groq-only configuration.
    return;
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Groq-only flow: attempt Groq endpoint and show response or error.
      final groqReply = await _sendMessageViaGroq(message);
      if (groqReply != null) {
        setState(() {
          _messages.add(ChatMessage(
            text: groqReply,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
        return;
      }

      // If we reach here, Groq did not return a reply. Show debug info if available.
      setState(() {
        final debug = _lastGroqDebug;
        final messageText = debug == null || debug.isEmpty
            ? 'No response from Groq backend. Check endpoint/key in settings.'
            : 'No response from Groq backend. Debug: $debug';

        _messages.add(ChatMessage(
          text: messageText,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      print('Groq send error: $e');
      setState(() {
        _messages.add(ChatMessage(
          text: 'Error when calling Groq: ${e.toString()}',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
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
      final body = json.encode({
        'model': _groqModel,
        'messages': [
          {'role': 'user', 'content': prompt}
        ]
      });
      final headers = {
        'Content-Type': 'application/json',
        // Groq uses OpenAI-compatible format: Authorization: Bearer <key>
        'Authorization': 'Bearer $_groqApiKey',
      };

      final r = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 12));
      if (r.statusCode == 200) {
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
      } else {
        // Save debug info for UI visibility
        _lastGroqDebug = 'Groq POST failed: ${r.statusCode} ${r.body}';
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
      if (endpoint != null && endpoint.contains('/models/your-model/generate')) {
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
              const Text('Groq endpoint and API key (the app will call this directly)'),
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
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
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
                  actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
                ),
              );
            },
            child: const Text('Test'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _groqEndpoint = endpointController.text.trim();
                _groqApiKey = keyController.text.trim();
              });
              _saveChatConfig();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat settings saved.')));
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
      final body = json.encode({'input': 'ping'});
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $key',
      };
      final r = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 8));
      return 'Status: ${r.statusCode}\nBody:\n${r.body}';
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
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.white),
            SizedBox(width: 8),
            Text('Farming Assistant'),
          ],
        ),
        backgroundColor: const Color(0xFF0D5EF9),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openGroqSettingsDialog,
            tooltip: 'Chat settings (backend)',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  text: 'Chat cleared! How can I help you?',
                  isUser: false,
                  timestamp: DateTime.now(),
                ));
              });
            },
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Assistant is typing...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask about farming...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF0D5EF9)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.mic, color: Colors.grey.shade600),
                          onPressed: () {
                            // TODO: Implement voice input
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🎤 Voice input coming soon!'),
                              ),
                            );
                          },
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: () => _sendMessage(_messageController.text),
                    backgroundColor: const Color(0xFF0D5EF9),
                    mini: true,
                    child: const Icon(Icons.send, color: Colors.white),
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

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFF0D5EF9),
              radius: 16,
              child: const Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF0D5EF9)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
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
                        fontSize: 14,
                      ),
                    )
                  else
                    MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        strong: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        em: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                        h1: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        h2: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        h3: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        listBullet: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        code: TextStyle(
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFF0D5EF9),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green.shade400,
              radius: 16,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
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
