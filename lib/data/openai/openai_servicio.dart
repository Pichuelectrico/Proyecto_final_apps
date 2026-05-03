import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class OpenAIServicio {
  static const String _baseUrl = 'https://api.openai.com/v1/responses';
  final String apiKey;

  OpenAIServicio({String? apiKey})
      : apiKey = apiKey ?? const String.fromEnvironment('OPENAI_API_KEY');

  Future<String> generarCaption(String imagePath) async {
    if (apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY no esta configurada');
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Archivo no encontrado: $imagePath');
    }

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = imagePath.toLowerCase().endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'input': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'input_text',
                'text':
                    'Genera un caption corto y casual en espanol para esta foto. Maximo 10 palabras.',
              },
              {
                'type': 'input_image',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image',
                },
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error OpenAI: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    final outputText = data['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return outputText.trim();
    }

    final output = data['output'];
    if (output is List) {
      for (final item in output) {
        final content = item['content'];
        if (content is List) {
          for (final part in content) {
            final text = part['text'];
            if (text is String && text.trim().isNotEmpty) {
              return text.trim();
            }
          }
        }
      }
    }

    throw Exception('Respuesta de OpenAI sin texto');
  }
}
