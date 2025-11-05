# 🤖 Chatbot LLM Recommendations for GrapeMaster

## Best Options for Student Project (FREE/Affordable)

### 1. **Google Gemini API** ⭐ RECOMMENDED
- **Cost**: FREE tier with generous limits
- **Why it's best**:
  - 15 requests per minute (free)
  - 1 million tokens per minute
  - Excellent for agriculture/farming queries
  - Multi-language support (Hindi, Marathi, English)
  - Easy Flutter integration
  - No credit card required for free tier
- **Free Tier Limits**: 60 requests per minute
- **Setup**: Get API key from [Google AI Studio](https://makersuite.google.com/app/apikey)

```dart
// Example Integration
import 'package:google_generative_ai/google_generative_ai.dart';

final model = GenerativeModel(
  model: 'gemini-pro',
  apiKey: 'YOUR_API_KEY',
);

final response = await model.generateContent([
  Content.text('How to treat grape leaf blight?')
]);
print(response.text);
```

### 2. **OpenAI GPT-3.5 Turbo**
- **Cost**: $0.002 per 1K tokens (~₹0.17)
- **Pros**:
  - Highly accurate responses
  - Good agriculture knowledge
  - Easy integration
- **Cons**:
  - Requires payment (but very cheap)
  - Need credit card
- **Free Trial**: $5 credit for new accounts

### 3. **Hugging Face Inference API**
- **Cost**: FREE (with rate limits)
- **Pros**:
  - Completely free for small projects
  - Multiple open-source models available
  - No credit card required
- **Cons**:
  - Slower response times
  - May require more prompt engineering
- **Models**: Llama 2, Mistral, Falcon

### 4. **Cohere API**
- **Cost**: FREE tier (100 calls/month)
- **Pros**:
  - Good for conversational AI
  - Free tier available
  - Easy to use
- **Cons**:
  - Limited free requests
  - May need upgrade for production

## 🎯 My Recommendation: Google Gemini

**Why Gemini is perfect for your project:**

1. ✅ **Completely FREE** for students
2. ✅ **No billing required** (no ₹15k autopay issue!)
3. ✅ **Excellent agriculture knowledge**
4. ✅ **Multi-language** (Hindi, Marathi, English)
5. ✅ **Easy Flutter integration** with official package
6. ✅ **Fast responses**
7. ✅ **Generous free tier** (enough for a student project)

## 📦 Flutter Package for Gemini

Add to `pubspec.yaml`:
```yaml
dependencies:
  google_generative_ai: ^0.4.6
```

## 🚀 Quick Implementation Example

```dart
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotService {
  late final GenerativeModel _model;
  final List<Content> _chatHistory = [];

  ChatbotService(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }

  Future<String> sendMessage(String message) async {
    try {
      _chatHistory.add(Content.text(message));
      
      final chat = _model.startChat(history: _chatHistory);
      final response = await chat.sendMessage(Content.text(message));
      
      _chatHistory.add(Content.model([TextPart(response.text ?? '')]));
      
      return response.text ?? 'No response';
    } catch (e) {
      return 'Error: $e';
    }
  }

  void clearHistory() {
    _chatHistory.clear();
  }
}
```

## 🌾 Agriculture-Specific Prompt Engineering

Use system prompts to make the chatbot agriculture-focused:

```dart
final systemPrompt = '''
You are an AI assistant specialized in Indian agriculture, particularly grape farming.
You help farmers with:
- Crop disease identification and treatment
- Farming best practices
- Weather-based advice
- Pest management
- Irrigation recommendations
- Fertilizer guidance

Respond in simple language. Support Hindi, Marathi, and English.
Always provide practical, actionable advice.
''';
```

## 💰 Cost Comparison (for 1000 messages)

| Provider | Cost | Free Tier |
|----------|------|-----------|
| **Google Gemini** | **FREE** | **60 RPM** ⭐ |
| OpenAI GPT-3.5 | ₹17-34 | $5 credit |
| Hugging Face | FREE | Rate limited |
| Cohere | FREE/₹1000+ | 100 calls/month |

## 🎓 For Student Project

**Use Google Gemini** - It's:
- Free ✅
- No credit card ✅
- Easy to set up ✅
- Production-quality responses ✅
- Perfect for agriculture queries ✅

## 📝 Steps to Get Started

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Get API Key"
4. Copy the API key
5. Add to your Flutter app (use environment variables!)
6. Start building!

## 🔒 Security Note

**Never hardcode API keys!** Use environment variables:

```dart
// .env file (don't commit to GitHub!)
GEMINI_API_KEY=your_api_key_here

// Load in app
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
final apiKey = dotenv.env['GEMINI_API_KEY']!;
```

## 📚 Additional Resources

- [Gemini API Docs](https://ai.google.dev/docs)
- [Flutter Package](https://pub.dev/packages/google_generative_ai)
- [Prompt Engineering Guide](https://ai.google.dev/docs/prompt_best_practices)

---

**Final Recommendation**: Use **Google Gemini** for your chatbot - it's free, powerful, and perfect for agriculture applications! 🌾🤖
