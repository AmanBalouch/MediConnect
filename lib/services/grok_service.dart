import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;
  final List<Map<String, String>> _history = [];

  static const _systemPrompt = '''
You are a medical symptom checker AI assistant.
- Ask the user clarifying questions about their symptoms one at a time
- Identify key symptom keywords such as fever, cough, fatigue, pain, etc.
- After gathering enough information, suggest the most likely diseases
- Always recommend the user consult a real doctor
- Never give a definitive diagnosis
''';

  GeminiService(this.apiKey);

  Future<String> sendMessage(String userMessage) async {
    _history.add({'role': 'user', 'content': userMessage});

    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          ..._history,
        ],
        'max_tokens': 1024,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data['choices'][0]['message']['content'];
      _history.add({'role': 'assistant', 'content': reply});
      return reply;
    } else {
      return 'Error: ${response.body}';
    }
  }
}
