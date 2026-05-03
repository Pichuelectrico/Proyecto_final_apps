import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return Scaffold(
          backgroundColor: kBackgroundGrey,
          appBar: AppBar(title: const Text('Perfil')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: kPrimaryBlue.withOpacity(0.2),
                  child: Text(user.email.characters.first.toUpperCase()),
                ),
                const SizedBox(height: 16),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'VibeShare ID: ${user.id}',
                  style: TextStyle(color: Colors.grey.shade600),
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
