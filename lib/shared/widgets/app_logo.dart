import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.showTitle = true,
    this.iconSize = 28,
    this.titleStyle,
  });

  final bool showTitle;
  final double iconSize;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize + 8,
          height: iconSize + 8,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.pets,
            color: Colors.white,
            size: iconSize * 0.65,
          ),
        ),
        if (showTitle) ...[
          const SizedBox(width: 8),
          Text(
            'Agenda Pet',
            style: titleStyle ??
                Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
          ),
        ],
      ],
    );
  }
}
