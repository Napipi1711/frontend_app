import 'package:flutter/material.dart';

class UserTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;

  const UserTopBar({
    super.key,
    this.title = "FoodApp",
    this.onSearchTap,
    this.onCartTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.orange,
      elevation: 2,
      title: Row(
        children: [
          const Icon(Icons.fastfood, size: 28, color: Colors.white),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 20)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchTap,
          tooltip: "Search",
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: onCartTap,
          tooltip: "Cart",
        ),
      ],
    );
  }
}
