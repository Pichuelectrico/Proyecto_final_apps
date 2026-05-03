import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants.dart';
import '../../dominio/casos_uso/cargar_imagen.dart';
import '../../dominio/casos_uso/validar_imagen.dart';
import '../providers/auth_provider.dart';
import '../providers/friends_provider.dart';
import '../providers/image_provider.dart';
import '../widgets/friend_selector.dart';
import 'gallery_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        final friendsAsync = ref.watch(friendsProvider(user.id));

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: const [HomePage(), GalleryPage(), ProfilePage()],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Feed'),
              NavigationDestination(icon: Icon(Icons.collections), label: 'Enviadas'),
              NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
            ],
          ),
          floatingActionButton: friendsAsync.when(
            data: (friends) {
              if (friends.isEmpty) {
                return FloatingActionButton.extended(
                  backgroundColor: kSecondaryGreen,
                  icon: const Icon(Icons.group_add),
                  label: const Text('Sin amigos'),
                  onPressed: () {},
                );
              }
              return FloatingActionButton(
                backgroundColor: kSecondaryGreen,
                child: const Icon(Icons.add_a_photo),
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    showDragHandle: true,
                    builder: (context) {
                      return _ShareSheet(userId: user.id);
                    },
                  );
                  ref.invalidate(incomingImagesProvider(user.id));
                  ref.invalidate(outgoingImagesProvider(user.id));
                },
              );
            },
            error: (_, __) => null,
            loading: () => null,
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

class _ShareSheet extends ConsumerStatefulWidget {
  final String userId;

  const _ShareSheet({required this.userId});

  @override
  ConsumerState<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends ConsumerState<_ShareSheet> {
  final _captionController = TextEditingController();
  String? _selectedImagePath;
  Friend? _selectedFriend;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsProvider(widget.userId));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: friendsAsync.when(
        data: (friends) {
          if (friends.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(child: Text('Agrega amigos para compartir.')),
            );
          }
          _selectedFriend ??= friends.first;
          final selected = _selectedFriend;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              Text(
                'Comparte una imagen',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              FriendSelector(
                friends: friends,
                selected: selected,
                onSelected: (friend) => setState(() => _selectedFriend = friend),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(kCornerRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _captionController,
                      decoration: const InputDecoration(
                        labelText: 'Mensaje',
                        hintText: 'Escribe una vibe',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  setState(() => _errorMessage = null);
                                  final picker = ref.read(imagePickerProvider);
                                  final source = await showModalBottomSheet<ImageSource>(
                                    context: context,
                                    builder: (context) => SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.photo_library),
                                            title: const Text('Galeria'),
                                            onTap: () => Navigator.of(context)
                                                .pop(ImageSource.gallery),
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.photo_camera),
                                            title: const Text('Camara'),
                                            onTap: () => Navigator.of(context)
                                                .pop(ImageSource.camera),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                  if (source == null) return;
                                  final picked = await picker.pickImage(
                                    source: source,
                                    imageQuality: 85,
                                  );
                                  if (picked == null) return;
                                  setState(() => _selectedImagePath = picked.path);
                                },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Seleccionar'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedImagePath?.isNotEmpty == true
                                ? 'Imagen lista'
                                : 'Sin imagen seleccionada',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSecondaryGreen,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                setState(() => _errorMessage = null);
                                final selected = _selectedFriend;
                                final imagePath = _selectedImagePath;
                                if (selected == null) {
                                  setState(() => _errorMessage = 'Selecciona un amigo.');
                                  return;
                                }
                                if (imagePath == null || imagePath.isEmpty) {
                                  setState(() => _errorMessage = 'Selecciona una imagen.');
                                  return;
                                }
                                final isValid =
                                    await ValidarImagen().ejecutar(imagePath);
                                if (!isValid) {
                                  setState(() => _errorMessage = 'Imagen no valida.');
                                  return;
                                }
                                setState(() => _isSubmitting = true);
                                try {
                                  final repo = ref.read(imageRepoProvider);
                                  final useCase = CargarImagen(repo);
                                  await useCase.ejecutar(
                                    senderId: widget.userId,
                                    receiverId: selected.id,
                                    localPath: imagePath,
                                    caption: _captionController.text.trim().isEmpty
                                        ? null
                                        : _captionController.text.trim(),
                                  );
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                } catch (error) {
                                  setState(() => _errorMessage = '$error');
                                } finally {
                                  if (mounted) {
                                    setState(() => _isSubmitting = false);
                                  }
                                }
                              },
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Enviar vibe'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        error: (error, _) => Center(child: Text('Error: $error')),
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
