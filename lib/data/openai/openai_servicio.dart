import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class OpenAIServicio {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  
  // Configura tu API key usando --dart-define=OPENAI_API_KEY=...
  static const String _apiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );
  
  final List<String> _fallbackCaptions = [
    'Capturando momentos especiales ✨',
    'Un vibe que compartir 💫',
    'Momentos inolvidables 📸',
    'La vida es mejor con amigos 🌟',
    'Compartiendo buenas vibras 💚',
    'Recuerdos que perduran ✨',
  ];

  /// Genera un caption sugerido usando OpenAI o fallback aleatorio
  Future<String> generarCaptionSugerido({String? contextoImagen}) async {
    try {
      // Si no hay API key configurada, usar fallback
      if (_apiKey.isEmpty) {
        return _getFallbackCaption();
      }
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'Eres un asistente creativo que genera captions cortos y divertidos para fotos compartidas entre amigos en una app llamada VibeShare. Genera captions de máximo 50 caracteres en español, casuales y amigables.'
            },
            {
              'role': 'user',
              'content': contextoImagen != null 
                ? 'Genera un caption corto para esta foto: $contextoImagen'
                : 'Genera un caption corto y divertido para compartir una foto con un amigo'
            }
          ],
          'max_tokens': 60,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final caption = data['choices'][0]['message']['content']?.toString().trim();
        if (caption != null && caption.isNotEmpty) {
          return caption;
        }
      }
      
      // Si falla la API, usar fallback
      return _getFallbackCaption();
    } catch (e) {
      return _getFallbackCaption();
    }
  }

  /// Obtiene una opción de caption aleatoria del fallback
  String _getFallbackCaption() {
    final random = Random();
    return _fallbackCaptions[random.nextInt(_fallbackCaptions.length)];
  }

  /// Obtiene todas las opciones de fallback para mostrar como alternativas
  List<String> getFallbackOptions() {
    return List.from(_fallbackCaptions);
  }
}
