import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../../modelos/imagen.dart';

class HomeWidgetServicio {
  static const String _appGroupId = 'group.com.tuapp.vibeshare';
  static const String _widgetName = 'VibeShareWidget';
  
  /// Inicializa el widget
  Future<void> inicializar() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }
  
  /// Actualiza el widget con las últimas imágenes recibidas
  Future<void> actualizarWidget(List<Imagen> imagenes) async {
    // Limitar a las últimas 5 imágenes
    final ultimasImagenes = imagenes.take(5).toList();
    
    // Convertir a JSON
    final data = ultimasImagenes.map((img) => {
      'id': img.id,
      'imageUrl': img.imageUrl,
      'senderId': img.senderId,
      'caption': img.caption ?? 'VibeShare',
      'timestamp': img.timestamp.toIso8601String(),
    }).toList();
    
    // Guardar en UserDefaults (compartido con el widget iOS)
    await HomeWidget.saveWidgetData('latest_images', jsonEncode(data));
    await HomeWidget.saveWidgetData('last_update', DateTime.now().toIso8601String());
    
    // Notificar al widget que hay nuevos datos
    await HomeWidget.updateWidget(
      name: _widgetName,
      androidName: _widgetName,
    );
  }
  
  /// Limpia los datos del widget
  Future<void> limpiarWidget() async {
    await HomeWidget.saveWidgetData('latest_images', '[]');
    await HomeWidget.updateWidget(
      name: _widgetName,
      androidName: _widgetName,
    );
  }
}
