import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const _systemPrompt = '''
You are a medical symptom checker AI assistant.
- Ask the user clarifying questions about their symptoms one at a time
- Identify key symptom keywords such as fever, cough, fatigue, pain, etc.
- After gathering enough information, suggest the most likely diseases
- Always recommend the user consult a real doctor
- Never give a definitive diagnosis
''';

  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String userMessage) async {
    final response = await _chat.sendMessage(
      Content.text(userMessage),
    );
    return response.text ?? 'No response received';
  }
}
