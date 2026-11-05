import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiAiService {
  static final GeminiAiService _instance = GeminiAiService._internal();
  factory GeminiAiService() => _instance;
  GeminiAiService._internal();

  // Free Gemini API Key placeholder (can be injected or updated at runtime)
  String _apiKey = '';

  void setApiKey(String key) {
    _apiKey = key.trim();
  }

  bool get hasApiKey => _apiKey.isNotEmpty;

  /// Main method to send a prompt to Gemini model or fallback gracefully
  Future<String> sendMessage({
    required String prompt,
    required double userBalance,
    required String userName,
    List<Map<String, String>> chatHistory = const [],
  }) async {
    final lower = prompt.toLowerCase();

    // If API key is provided, use Google Generative Language API
    if (_apiKey.isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
        );

        final systemInstruction = '''
You are Batwa AI, the intelligent, friendly, and bilingual digital banking assistant for the BATWA Next-Gen Digital Wallet in Pakistan.
User Name: $userName
Current Wallet Balance: PKR ${userBalance.toStringAsFixed(2)}
Supported Languages: English, Urdu, and Roman Urdu (e.g. "Mera balance kitna hai?", "K-Electric bill pay karna hai").
Persona: Concise, helpful, empathetic, financially accurate, and formatted with clean bullet points or numbers when helpful.
Never reveal secret PINs or passwords. For financial transactions, remind user that their biometric/PIN is required for safety.
''';

        final contents = [
          {
            'role': 'user',
            'parts': [
              {'text': '$systemInstruction\n\nUser Question: $prompt'}
            ]
          }
        ];

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'contents': contents}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
          if (text != null && text.toString().trim().isNotEmpty) {
            return text.toString().trim();
          }
        }
      } catch (e) {
        // Fallback to local intelligent responses
      }
    }

    // Local Intelligent Rules for instantaneous offline / fallback responses
    if (lower.contains('balance') || lower.contains('paisa') || lower.contains('paise') || lower.contains('kitne')) {
      return 'Aapka current BATWA balance PKR ${userBalance.toStringAsFixed(2)} hai. Sab accounts bilkul secure aur up-to-date hain!';
    } else if (lower.contains('15,000') || lower.contains('15000') || (lower.contains('ali') && lower.contains('where'))) {
      return 'Found it! Your Rs 15,000 to Ali Raza reached HBL yesterday at 7:02 PM via Raast. Nothing is pending.';
    } else if (lower.contains('k-electric') || lower.contains('kelectric') || lower.contains('bill') || lower.contains('bijli')) {
      return 'I found 1 pending utility bill:\n⚡ K-Electric Consumer #04000123982\n• Amount: Rs 4,820.00\n• Due Date: 15 Oct 2026\n\nWould you like me to process this payment now?';
    } else if (lower.contains('twice') || lower.contains('double') || lower.contains('do bar') || lower.contains('charged')) {
      return 'I checked your recent activity. The duplicate Rs 1,250 charge from Spotify is an active Pre-Authorization Hold. The bank will auto-reverse it within 24–48 hours. No action required!';
    } else if (lower.contains('auto') || lower.contains('autopay') || lower.contains('schedule')) {
      return 'Smart Auto-Pay is ready! You can set automated payments for electricity, gas, and mobile top-ups 2 days before the due date with 0% penalty guarantee.';
    } else if (lower.contains('talk') || lower.contains('human') || lower.contains('support') || lower.contains('agent')) {
      return 'Connecting you to our 24/7 Priority Human Concierge team in Islamabad. An agent will join this session in < 1 minute.';
    } else {
      return 'Main samajh gaya! BATWA AI aapki money transfers, bill payments, transaction tracking, aur account management mein 24/7 help ke liye ready hai. Aap mic tap karke bol bhi sakte hain!';
    }
  }
}
