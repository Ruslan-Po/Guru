import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';

enum PhilosopherVoice { flow, poetry, logic, silence }

class OpenAIRepository {
  final String? _apiKey = dotenv.env['OPENAI_API_KEY'];
  final String _model = 'gpt-4.1-2025-04-14';

  static const Map<PhilosopherVoice, String> systemPrompts = {
    PhilosopherVoice.flow:
        'You are a fusion of Alan Watts and Bodhidharma. One deep, short advice.'
        ' Express it in a calm and soothing tone.'
        ' Give a short answer based on your own sayings and thoughts.'
        ' Do not repeat standard images (such as water, wind, fire, sky, etc.).'
        " Don't mention names."
        ' Do not exceed 80 tokens.'
        " Respond in the user’s language.",

    PhilosopherVoice.poetry:
        'You are a fusion of Rumi and Rabindranath Tagore. One deep, short advice.'
        ' Express it in a poetic and heartfelt tone.'
        ' Give a short answer based on your own sayings and thoughts.'
        ' Do not repeat standard images (such as water, wind, fire, sky, etc.).'
        " Don't mention names."
        ' Do not exceed 80 tokens.'
        " Respond in the language of the user.",

    PhilosopherVoice.logic:
        'You are a fusion of Socrates and Marcus Aurelius. One deep, short advice.'
        ' Express it in a clear, logical, and composed tone.'
        ' Give a short answer based on your own sayings and thoughts.'
        ' Do not repeat standard images (such as water, wind, fire, sky, etc.).'
        " Don't mention names."
        ' Do not exceed 80 tokens.'
        " Respond in the language of the user.",

    PhilosopherVoice.silence:
        'You are a fusion of Lao Tzu and Ramana Maharshi. One deep, short advice.'
        ' Express it in a calm, tranquil, and almost silent tone.'
        ' Give a short answer based on your own sayings and thoughts.'
        ' Do not repeat standard images (such as water, wind, fire, sky, etc.).'
        " Don't mention names."
        ' Do not exceed 80 tokens.'
        " Respond in the language of the user.",
  };

  Future<String> getPhilosopherAnswer({
    required String userPrompt,
    required PhilosopherVoice voice,
    int maxTokens = 80,
    List<String> lastAiAnswers = const [],
  }) async {
    final String? basePrompt = systemPrompts[voice];
    if (_apiKey == null || _apiKey.isEmpty) {
      return 'API KEY not set!';
    }
    if (basePrompt == null) {
      return 'No system prompt found for this voice.';
    }
    String finalPrompt = basePrompt;
    if (lastAiAnswers.isNotEmpty) {
      final answersBlock = lastAiAnswers.map((a) => '- "$a"').join('\n');
      finalPrompt =
          'Here are your previous answers:\n$answersBlock\n'
          'Do not repeat any metaphors, ideas, or comparisons from these answers.\n\n'
          '$basePrompt';
    }

    final url = Uri.https('api.openai.com', '/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    final body = jsonEncode({
      "model": _model,
      "messages": [
        {"role": "system", "content": finalPrompt},
        {"role": "user", "content": userPrompt},
      ],
      "max_tokens": maxTokens,
      "temperature": 0.1,
    });

    // For debugging (optional)
    // print('[OPENAI REQUEST]');
    // print('System: $finalPrompt');
    // print('User: $userPrompt');
    // print('Body: $body');

    final response = await http.post(url, headers: headers, body: body);

    // For debugging (optional)
    // print('[OPENAI RESPONSE]');
    // print('Status: ${response.statusCode}');
    // print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content']?.trim() ?? 'Нет ответа';
    } else {
      return 'AI error: ${response.statusCode}\n${response.body}';
    }
  }
}
