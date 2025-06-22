import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart'; // Make sure path is correct for your project

class Appbar extends StatelessWidget implements PreferredSizeWidget {
  const Appbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleSpacing: 0, // Prevents default extra spacing
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: AppColors.primaryDark, size: 28), // 🌿 Leaf icon
                const SizedBox(width: 8),
                Text(
                  "QUEEZ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.notifications_none, color: AppColors.iconActive, size: 26),
              onPressed: () {
                // Handle notification tap
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
