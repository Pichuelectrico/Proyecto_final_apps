import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../modelos/friend.dart';
import '../../modelos/imagen.dart';
import '../providers/friends_provider.dart';

class ImageCardWithSender extends ConsumerWidget {
  final Imagen imagen;
  final String currentUserId;

  const ImageCardWithSender({
    super.key,
    required this.imagen,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider(currentUserId));
    
    return friendsAsync.when(
      data: (friends) {
        // Buscar el amigo que envió la imagen (senderId)
        final sender = friends.firstWhere(
          (f) => f.id == imagen.senderId,
          orElse: () => Friend(
            id: imagen.senderId,
            nombre: 'Amigo',
            email: '',
          ),
        );
        
        return _buildCard(context, sender);
      },
      loading: () => _buildCard(context, null),
      error: (_, __) => _buildCard(context, null),
    );
  }

  Widget _buildCard(BuildContext context, Friend? sender) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCornerRadiusLg),
      ),
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kCornerRadiusLg),
        child: Stack(
          children: [
            // Imagen principal
            AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(
                imageUrl: imagen.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, _) => Container(
                  color: kBackgroundGrey,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
                errorWidget: (context, _, __) => Container(
                  color: kBackgroundGrey,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined, size: 48),
                ),
              ),
            ),
            
            // Degradado superior para el perfil del remitente
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(153), // 0.6 opacity
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar del remitente
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: kSecondaryGreen,
                        child: Text(
                          sender?.nombre.characters.first.toUpperCase() ?? 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nombre del remitente
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sender?.nombre ?? 'Amigo',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Te envió una vibe',
                            style: TextStyle(
                              color: Colors.white.withAlpha(204), // 0.8 opacity
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Timestamp
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(102), // 0.4 opacity
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatTimestamp(imagen.timestamp),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Degradado inferior para el caption
            if (imagen.caption != null && imagen.caption!.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withAlpha(179), // 0.7 opacity
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    imagen.caption!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
}
