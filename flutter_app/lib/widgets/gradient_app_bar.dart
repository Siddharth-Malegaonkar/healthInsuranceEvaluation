import 'package:flutter/material.dart';

/// A reusable gradient app bar that wraps [AppBar] with a blue gradient.
///
/// Usage:
/// ```dart
/// appBar: GradientAppBar(title: 'My Screen'),
/// ```
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          letterSpacing: 0.3,
        ),
      ),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          ),
        ),
      ),
    );
  }
}
