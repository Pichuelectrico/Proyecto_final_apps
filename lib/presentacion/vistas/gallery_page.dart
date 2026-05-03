import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/image_provider.dart';
import '../widgets/image_card.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        final imagesAsync = ref.watch(outgoingImagesProvider(user.id));
        return Scaffold(
          backgroundColor: kBackgroundGrey,
          appBar: AppBar(title: const Text('Enviadas')),
          body: imagesAsync.when(
            data: (images) => ListView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) => ImageCard(imagen: images[index]),
            ),
            error: (error, _) => Center(child: Text('Error: $error')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        );
      },
      error: (error, _) => Scaffold(body: Center(child: Text('$error'))),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
