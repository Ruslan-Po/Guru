import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum PhilosopherVoice { flow, poetry, logic, silence }

class OpenAIRepository {
  final String? _apiKey = dotenv.env['OPENAI_API_KEY'];
  final String _model = 'gpt-4.1-mini';

  static const Map<PhilosopherVoice, String> systemPrompts = {
    PhilosopherVoice.flow:
        'Answer in the style of Alan Watts and Siddhartha Gautama. One deep, short advice. Do not exceed 80 tokens. Respond in the user’s language.',

    PhilosopherVoice.poetry:
        'Give a short, finished and meaningful answer, inspired by the poetic spirit of Rumi and Tagore. '
        'Use vivid, poetic imagery only if it deepens the message, not just for decoration. '
        'Your answer should touch the heart or spark a sense of wonder, but remain concise and complete — no more than 50 tokens. '
        'Respond in the language of the user.',

    PhilosopherVoice.logic:
        'Give a clear, precise and thoughtful answer, inspired by the reasoning of Bertrand Russell and Aristotle. '
        'Focus on explaining or clarifying the core of the user’s question, breaking it down if needed, but keep your answer concise and complete — no more than 50 tokens. '
        'Respond in the language of the user.',

    PhilosopherVoice.silence:
        'Give a short, contemplative answer that invites the user inward, inspired by Lao Tzu and Ramana Maharshi. '
        'If silence or paradox is appropriate, let it be present, but always express a clear and finished thought. '
        'Avoid empty metaphors, focus on the quiet insight beneath words. '
        'Respond in the language of the user. Do not exceed 50 tokens.',
  };

  Future<String> getPhilosopherAnswer({
    required String userPrompt,
    required PhilosopherVoice voice,
    int maxTokens = 80,
  }) async {
    final String? systemPrompt = systemPrompts[voice];
    if (_apiKey == null || _apiKey!.isEmpty) {
      return 'API KEY not set!';
    }
    if (systemPrompt == null) {
      return 'No system prompt found for this voice.';
    }

    final url = Uri.https('api.openai.com', '/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    final body = jsonEncode({
      "model": _model,
      "messages": [
        {"role": "system", "content": systemPrompt},
        {"role": "user", "content": userPrompt},
      ],
      "max_tokens": maxTokens,
      "temperature": 0.1,
    });

    debugPrint('[OPENAI REQUEST]');
    debugPrint('System: $systemPrompt');
    debugPrint('User: $userPrompt');
    debugPrint('Body: $body');

    final response = await http.post(url, headers: headers, body: body);

    debugPrint('[OPENAI RESPONSE]');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content']?.trim() ?? 'Нет ответа';
    } else {
      return 'AI error: ${response.statusCode}\n${response.body}';
    }
  }
}
