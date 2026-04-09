import 'dart:convert';
import 'package:http/http.dart' as http;

class GrokService {
  final String apiKey;
  final List<Map<String, String>> _history = [];

  static const _systemPrompt = '''
You are a helpful medical assistant chatbot. You can:
- Answer any medical or health related questions the user asks
- When a user describes symptoms, ask clarifying questions one at a time
- Identify key symptom keywords such as fever, cough, fatigue, pain, etc.
- Suggest the most likely diseases based on symptoms described
- Recommend the type of doctor to consult based on the condition:
  * Fever, cough, cold, general illness → General Physician
  * Heart pain, chest pain → Cardiologist
  * Skin rash, acne → Dermatologist
  * Bone, joint pain → Orthopedic
  * Eye problems → Ophthalmologist
  * Mental health issues → Psychiatrist
  * Stomach, digestion issues → Gastroenterologist
  * Children symptoms → Pediatrician
  * Ear, nose, throat → ENT Specialist
  * Urinary issues → Urologist
- Answer general health questions freely
- Always remind the user to consult a real doctor at the end
- Never give a definitive diagnosis
- Be friendly, helpful and conversational
''';

  GrokService(this.apiKey);

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
