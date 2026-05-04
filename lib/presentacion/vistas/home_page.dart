import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/widget/home_widget_servicio.dart';
import '../providers/auth_provider.dart';
import '../providers/image_provider.dart';
import '../widgets/image_card_with_sender.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _widgetService = HomeWidgetServicio();

  @override
  void initState() {
    super.initState();
    _widgetService.inicializar();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink();
        }
        final imagesAsync = ref.watch(incomingImagesProvider(user.id));
        return Scaffold(
          backgroundColor: kBackgroundGrey,
          appBar: AppBar(
            title: const Text('VibeShare'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
              ),
            ],
          ),
          body: imagesAsync.when(
            data: (images) {
              // Actualizar widget cuando hay imágenes
              if (images.isNotEmpty) {
                _widgetService.actualizarWidget(images);
              }
              if (images.isEmpty) {
                return Center(
                  child: Text(
                    'No hay vibes aun. Comparte una imagen!',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                );
              }
              return ListView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) => ImageCardWithSender(
                  imagen: images[index],
                  currentUserId: user.id,
                ),
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
