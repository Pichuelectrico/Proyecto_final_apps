import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../modelos/imagen.dart';

class ImageCard extends StatelessWidget {
  final Imagen imagen;

  const ImageCard({super.key, required this.imagen});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCornerRadiusLg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kCornerRadiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                imagen.caption ?? 'VibeShare',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
