import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:home_widget/home_widget.dart';
import '../../modelos/imagen.dart';

class HomeWidgetServicio {
  // IMPORTANTE: Este App Group debe configurarse en Xcode
  // 1. Selecciona el target Runner → Signing & Capabilities → + Capability → App Groups
  // 2. Crea el grupo: group.com.example.flutterBddFirebaseEjm40
  // 3. Haz lo mismo para el target VibeShareWidgetExtension
  static const String _appGroupId = 'group.com.example.flutterBddFirebaseEjm40';
  static const String _widgetName = 'VibeShareWidget';

  /// Inicializa el widget
  Future<void> inicializar() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Actualiza el widget con las últimas imágenes recibidas
  Future<void> actualizarWidget(List<Imagen> imagenes) async {
    developer.log('Actualizando widget con ${imagenes.length} imagenes');

    // Limitar a las últimas 5 imágenes
    final ultimasImagenes = imagenes.take(5).toList();

    // Convertir a JSON - incluir información del remitente
    final data = ultimasImagenes
        .map((img) => {
              'id': img.id,
              'imageUrl': img.imageUrl,
              'senderId': img.senderId,
              'senderName': 'Amigo', // TODO: Obtener nombre real del remitente
              'caption': img.caption ?? 'VibeShare',
              'timestamp': img.timestamp.toIso8601String(),
            })
        .toList();

    final jsonData = jsonEncode(data);
    developer.log('Guardando datos en widget: $jsonData');

    // Guardar en UserDefaults (compartido con el widget iOS)
    await HomeWidget.saveWidgetData('latest_images', jsonData);
    await HomeWidget.saveWidgetData(
        'last_update', DateTime.now().toIso8601String());

    // Notificar al widget que hay nuevos datos
    // En iOS, el widget se actualiza automáticamente cuando cambian los datos en UserDefaults
    // pero intentamos notificar de todos modos
    try {
      if (Platform.isIOS) {
        // Para iOS, intentamos actualizar el widget específico
        await HomeWidget.updateWidget(
          name: _widgetName,
          iOSName: _widgetName,
        );
      } else {
        await HomeWidget.updateWidget(
          name: _widgetName,
        );
      }
      developer.log('Widget actualizado exitosamente');
    } catch (e) {
      // El widget se actualizará automáticamente cuando iOS refresque el timeline
      developer.log('No se pudo notificar al widget (normal): $e');
    }
  }

  /// Limpia los datos del widget
  Future<void> limpiarWidget() async {
    await HomeWidget.saveWidgetData('latest_images', '[]');
    try {
      await HomeWidget.updateWidget(
        name: _widgetName,
        iOSName: Platform.isIOS ? _widgetName : null,
      );
    } catch (e) {
      developer.log('No se pudo limpiar widget: $e');
    }
  }
}
