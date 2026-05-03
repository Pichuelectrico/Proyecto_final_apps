import '../../data/openai/openai_servicio.dart';

class GenerarCaption {
  final OpenAIServicio servicio;

  GenerarCaption(this.servicio);

  Future<String> ejecutar(String imagePath) {
    return servicio.generarCaption(imagePath);
  }
}
