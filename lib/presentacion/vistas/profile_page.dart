import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/friends_provider.dart';
import '../widgets/add_friend_sheet.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        final friendsAsync = ref.watch(friendsProvider(user.id));

        return Scaffold(
          backgroundColor: kBackgroundGrey,
          appBar: AppBar(
            title: const Text('Perfil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    builder: (context) {
                      return AddFriendSheet(userId: user.id);
                    },
                  );
                },
                tooltip: 'Agregar amigo',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: kPrimaryBlue.withOpacity(0.2),
                  child: Text(
                    (user.nombre?.isNotEmpty == true
                            ? user.nombre!
                            : user.email)
                        .characters
                        .first
                        .toUpperCase(),
                  ),
                ),
                const SizedBox(height: 16),
                if (user.nombre?.isNotEmpty == true) ...[
                  Text(
                    user.nombre!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ] else ...[
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tus Amigos',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        friendsAsync.when(
                          data: (friends) {
                            if (friends.isEmpty) {
                              return Text(
                                'No tienes amigos aún. Presiona el botón + arriba para agregar uno.',
                                style: TextStyle(color: Colors.grey.shade600),
                              );
                            }
                            return Text(
                              '${friends.length} amigo${friends.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: kSecondaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                          loading: () => const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (error, _) => Text(
                            'Error: $error',
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'VibeShare ID: ${user.id}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
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
