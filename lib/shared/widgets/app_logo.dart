import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Logo de Agenda Pet: la marca (huella + calendario) en SVG transparente,
/// con el texto bicolor "Agenda Pet".
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
    final baseStyle = titleStyle ??
        Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/logo/agenda_pet_mark.svg',
          height: iconSize + 8,
        ),
        if (showTitle) ...[
          const SizedBox(width: 8),
          Text.rich(
            const TextSpan(
              children: [
                TextSpan(
                  text: 'Agenda',
                  style: TextStyle(color: AppColors.primaryDark),
                ),
                TextSpan(text: ' '),
                TextSpan(
                  text: 'Pet',
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
            style: baseStyle,
          ),
        ],
      ],
    );
  }
}
