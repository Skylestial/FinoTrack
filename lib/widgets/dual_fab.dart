import 'package:flutter/material.dart';

import '../utils/theme_colors.dart';

class DualFab extends StatelessWidget {
  const DualFab({
    super.key,
    required this.onAddPressed,
    required this.onAiPressed,
  });

  final VoidCallback onAddPressed;
  final VoidCallback onAiPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: onAiPressed,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                Positioned(
                  right: 10,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4C1D95),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'add-fab',
          onPressed: onAddPressed,
          backgroundColor: ThemeColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }
}
