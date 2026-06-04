import 'package:flutter/material.dart';

import '../utils/theme_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        if (trailing != null)
          DefaultTextStyle(
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: ThemeColors.textSecondaryFor(
                    Theme.of(context).brightness,
                  ),
                ),
            child: trailing!,
          ),
      ],
    );
  }
}
