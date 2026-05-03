import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/friends_provider.dart';
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
        final friendsAsync = ref.watch(friendsProvider(user.id));
        final imagesAsync = ref.watch(outgoingImagesProvider(user.id));
        return Scaffold(
          backgroundColor: kBackgroundGrey,
          appBar: AppBar(title: const Text('Enviadas')),
          body: imagesAsync.when(
            data: (images) {
              final friends = friendsAsync.value ?? const [];
              final friendsById = {
                for (final friend in friends) friend.id: friend,
              };
              return ListView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final imagen = images[index];
                  final friend = friendsById[imagen.receiverId];
                  final receiverLabel = friend?.nombre ?? imagen.receiverId;
                  return ImageCard(
                    imagen: imagen,
                    footer: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Para: $receiverLabel',
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (imagen.caption != null && imagen.caption!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              imagen.caption!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
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
