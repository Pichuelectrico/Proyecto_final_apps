import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../modelos/friend.dart';

class FriendSelector extends StatelessWidget {
  final List<Friend> friends;
  final Friend? selected;
  final ValueChanged<Friend> onSelected;

  const FriendSelector({
    super.key,
    required this.friends,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final friend = friends[index];
          final isActive = friend.id == selected?.id;
          return InkWell(
            onTap: () => onSelected(friend),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive ? kSecondaryGreen.withOpacity(0.15) : Colors.white,
                borderRadius: BorderRadius.circular(kCornerRadiusLg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: isActive ? kSecondaryGreen : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: kPrimaryBlue.withOpacity(0.15),
                    child: Text(friend.nombre.characters.first.toUpperCase()),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    friend.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    friend.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemCount: friends.length,
      ),
    );
  }
}
