import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ImgurServicio {
  static const String _clientId = '546c25a59c58ad7';
  static const String _apiUrl = 'https://api.imgur.com/3/image';
  static const MethodChannel _widgetChannel = MethodChannel('vibeshare_widget');

  Future<String> subirImagen(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Archivo no encontrado: $imagePath');
    }

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Client-ID $_clientId',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'image': base64Image, 'type': 'base64'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['link'];
    } else {
      throw Exception('Error al subir imagen: ${response.statusCode}');
    }
  }

  Future<void> cacheImageToWidget({
    required String imageUrl,
    String? caption,
    String? senderId,
    String? senderName,
  }) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode < 200 || response.statusCode >= 300) return;
    final bytes = response.bodyBytes;
    await _widgetChannel.invokeMethod('saveLatestImage', {
      'imageData': bytes,
      'caption': caption ?? '',
      'senderId': senderId ?? '',
      'senderName': senderName ?? '',
    });
  }
}
