import 'dart:convert';
import 'package:http/http.dart' as http;

class GrokService {
  final String apiKey =
      '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';
  final List<Map<String, String>> _history = [];

  static const _systemPrompt = '''
You are a helpful medical assistant chatbot. You can:
- Answer any medical or health related questions the user asks
- When a user describes symptoms, ask clarifying questions one at a time
- Identify key symptom keywords such as fever, cough, fatigue, pain, etc.
- Suggest the most likely diseases based on symptoms described
- Recommend the type of doctor to consult based on the symptoms
- Answer general health questions freely
- Always remind the user to consult a real doctor at the end
- Never give a definitive diagnosis
- Be friendly, helpful and conversational
''';

  GrokService();

  Future<String> sendMessage(String userMessage) async {
    try {
      _history.add({'role': 'user', 'content': userMessage});

      print('📤 Sending message to Grok API...');

      final response = await http
          .post(
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
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - Grok API not responding');
            },
          );

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'];
        _history.add({'role': 'assistant', 'content': reply});
        print('✅ Success: Got response from Grok');
        return reply;
      } else if (response.statusCode == 401) {
        print('❌ Error 401: Invalid API key');
        return 'Error: Invalid API key. Please check your Grok API key.';
      } else if (response.statusCode == 429) {
        print('❌ Error 429: Rate limit exceeded');
        return 'Error: Rate limit exceeded. Please try again later.';
      } else if (response.statusCode == 500) {
        print('❌ Error 500: Grok server error');
        return 'Error: Grok server error. Please try again later.';
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } on http.ClientException catch (e) {
      print('❌ Network Error: $e');
      return 'Error: Network error. Check your internet connection.';
    } catch (e) {
      print('❌ Exception: $e');
      return 'Error: $e';
    }
  }
}
