import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants.dart';
import '../../dominio/casos_uso/cargar_imagen.dart';
import '../../dominio/casos_uso/generar_caption.dart';
import '../../dominio/casos_uso/validar_imagen.dart';
import '../../modelos/friend.dart';
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
                  onPressed: () async {
                    final result = await showModalBottomSheet<_AddFriendResult>(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (context) {
                        return _AddFriendSheet(ownerId: user.id);
                      },
                    );
                    if (result == _AddFriendResult.added) {
                      ref.invalidate(friendsProvider(user.id));
                    }
                  },
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

enum _AddFriendResult { added }

class _AddFriendSheet extends ConsumerStatefulWidget {
  final String ownerId;

  const _AddFriendSheet({required this.ownerId});

  @override
  ConsumerState<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends ConsumerState<_AddFriendSheet> {
  final _formKey = GlobalKey<FormState>();
  final _friendIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _friendIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
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
              'Agregar amigo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _friendIdController,
              decoration: const InputDecoration(
                labelText: 'VibeShare ID',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el ID del amigo';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre (opcional)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo (opcional)',
              ),
              keyboardType: TextInputType.emailAddress,
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
                        if (!(_formKey.currentState?.validate() ?? false)) return;
                        setState(() => _errorMessage = null);
                        final friendId = _friendIdController.text.trim();
                        if (friendId == widget.ownerId) {
                          setState(() => _errorMessage = 'No puedes agregarte a ti mismo.');
                          return;
                        }
                        setState(() => _isSubmitting = true);
                        try {
                          final repo = ref.read(userRepoProvider);
                          await repo.addFriend(
                            ownerId: widget.ownerId,
                            friendId: friendId,
                            nombre: _nameController.text.trim().isEmpty
                                ? null
                                : _nameController.text.trim(),
                            email: _emailController.text.trim().isEmpty
                                ? null
                                : _emailController.text.trim(),
                          );
                          if (!mounted) return;
                          Navigator.of(context).pop(_AddFriendResult.added);
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
                    : const Text('Agregar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareSheetState extends ConsumerState<_ShareSheet> {
  final _captionController = TextEditingController();
  String? _selectedImagePath;
  Friend? _selectedFriend;
  bool _isSubmitting = false;
  bool _isGeneratingCaption = false;
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
          return SingleChildScrollView(
            child: Column(
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _isSubmitting || _isGeneratingCaption
                              ? null
                              : () async {
                                  final imagePath = _selectedImagePath;
                                  if (imagePath == null || imagePath.isEmpty) {
                                    setState(() =>
                                        _errorMessage = 'Selecciona una imagen primero.');
                                    return;
                                  }
                                  setState(() {
                                    _errorMessage = null;
                                    _isGeneratingCaption = true;
                                  });
                                  try {
                                    final servicio = ref.read(openAiServicioProvider);
                                    final useCase = GenerarCaption(servicio);
                                    final caption = await useCase.ejecutar(imagePath);
                                    _captionController.text = caption;
                                  } catch (error) {
                                    setState(() => _errorMessage = '$error');
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isGeneratingCaption = false);
                                    }
                                  }
                                },
                          icon: _isGeneratingCaption
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: const Text('Generar caption'),
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
            ),
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
