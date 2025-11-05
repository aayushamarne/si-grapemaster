# 🚀 Google Gemini API Setup Guide

## ✅ Step-by-Step Instructions

### Step 1: Get Your FREE Gemini API Key

1. **Open Google AI Studio**
   - Go to: https://makersuite.google.com/app/apikey
   - Or search "Google AI Studio" on Google

2. **Sign In**
   - Use your Google account (Gmail)
   - It's completely FREE - no credit card needed!

3. **Create API Key**
   - Click the **"Create API Key"** button
   - Choose **"Create API key in new project"** (recommended)
   - Your API key will be generated instantly

4. **Copy Your API Key**
   - It will look like: `AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXX`
   - **IMPORTANT**: Keep this key safe! Don't share it publicly.

---

### Step 2: Add API Key to Your App

1. **Open the chatbot file**
   ```
   lib/src/screens/chatbot_screen.dart
   ```

2. **Find this line** (around line 20):
   ```dart
   final String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
   ```

3. **Replace with your actual API key**:
   ```dart
   final String _apiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXX';
   ```

4. **Save the file** (Ctrl+S or Cmd+S)

---

### Step 3: Run Your App

```bash
flutter run
```

That's it! Your chatbot is now powered by Google Gemini AI! 🎉

---

## 🔒 Security Best Practices

### ⚠️ For Student Project (Quick & Easy)
Just paste the API key directly in the code as shown above. This is fine for:
- College projects
- Assignments
- Local development
- Testing

### 🔐 For Production Apps (Advanced)

**Use Environment Variables:**

1. **Create a `.env` file** in your project root:
   ```
   GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

2. **Add `.env` to `.gitignore`**:
   ```
   .env
   ```

3. **Add flutter_dotenv package**:
   ```yaml
   # pubspec.yaml
   dependencies:
     flutter_dotenv: ^5.1.0
   ```

4. **Load in your app**:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';

   void main() async {
     await dotenv.load();
     final apiKey = dotenv.env['GEMINI_API_KEY']!;
     // ...
   }
   ```

---

## 📊 Free Tier Limits

Google Gemini FREE tier includes:

| Feature | Limit |
|---------|-------|
| Requests per minute | 60 RPM |
| Tokens per minute | 32,000 TPM |
| Daily requests | 1,500 RPD |
| Cost | **FREE** ✅ |

**Perfect for student projects!** 🎓

---

## 🧪 Test Your Chatbot

Once you've added the API key, test with these questions:

1. **"How to treat grape powdery mildew?"**
2. **"What fertilizer should I use for grapes in March?"**
3. **"How often should I water my grape vineyard?"**
4. **"What are common grape pests in India?"**
5. **"When is the best time to prune grape vines?"**

The AI will provide detailed, context-aware responses! 🌾

---

## ❌ Troubleshooting

### Error: "API key not configured"
- Make sure you replaced `YOUR_GEMINI_API_KEY_HERE` with your actual key
- Check for typos in the API key
- Ensure the key is wrapped in quotes: `'AIzaSy...'`

### Error: "API key not valid"
- Go back to Google AI Studio and regenerate the key
- Make sure you copied the entire key
- Check if there are any extra spaces

### Error: "Quota exceeded"
- You've hit the free tier limit (60 requests/minute)
- Wait a minute and try again
- For student projects, this is usually enough!

### Error: "Network error"
- Check your internet connection
- Make sure your device/emulator has internet access
- Try on a different network if issues persist

---

## 🌟 Advanced Features

### Multi-language Support

The chatbot automatically supports:
- 🇬🇧 **English**
- 🇮🇳 **Hindi** (हिंदी)
- 🇮🇳 **Marathi** (मराठी)

Just ask in any language!

**Example:**
- English: "How to control grape pests?"
- Hindi: "अंगूर के कीटों को कैसे नियंत्रित करें?"
- Marathi: "द्राक्षातील किडे कसे नियंत्रित करावे?"

### Conversation Memory

The chatbot remembers your previous messages in the same session, so you can have natural conversations:

```
You: "What causes grape leaf blight?"
AI: [Detailed explanation]

You: "How do I treat it?"
AI: [Treatment specific to leaf blight - remembers context!]
```

---

## 📱 What You Get

✅ **Real AI responses** - Not pre-programmed answers
✅ **Context-aware** - Remembers conversation history
✅ **Multi-language** - Supports Hindi, Marathi, English
✅ **Agriculture-focused** - Specialized in grape farming
✅ **Free forever** - No billing required
✅ **Fast responses** - Usually < 2 seconds
✅ **Professional quality** - Production-ready

---

## 🎓 For Your College Project

This implementation:
- ✅ Shows real AI integration
- ✅ Demonstrates API usage
- ✅ Professional-looking UI
- ✅ Error handling included
- ✅ Loading states
- ✅ Chat history
- ✅ Mobile responsive

**Perfect for project demonstrations!** 🌟

---

## 📚 Additional Resources

- **Gemini API Docs**: https://ai.google.dev/docs
- **Flutter Package**: https://pub.dev/packages/google_generative_ai
- **API Limits**: https://ai.google.dev/pricing
- **Examples**: https://ai.google.dev/examples

---

## 💡 Pro Tips

1. **Don't commit API keys to GitHub!** Use `.gitignore`
2. **Test locally first** before deployment
3. **Monitor your usage** at https://makersuite.google.com
4. **Rate limiting**: If you hit limits, add delays between requests
5. **Backup your key**: Save it somewhere safe

---

## 🎉 You're All Set!

Your GrapeMaster app now has a fully functional AI chatbot powered by Google Gemini!

**Next Steps:**
1. Get your API key from Google AI Studio
2. Replace `YOUR_GEMINI_API_KEY_HERE` in `chatbot_screen.dart`
3. Run the app
4. Start chatting! 🚀

---

**Need Help?** 
- Check the troubleshooting section above
- Visit Google AI Studio for API key issues
- Review the error messages in the app - they're helpful!

Happy Farming! 🌾🤖
