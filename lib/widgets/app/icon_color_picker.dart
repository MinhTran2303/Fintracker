import 'package:fintracker/data/icons.dart';
import 'package:fintracker/theme/app_radius.dart';
import 'package:fintracker/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class IconColorPicker extends StatelessWidget {
  final Color selectedColor;
  final IconData selectedIcon;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<IconData> onIconChanged;

  const IconColorPicker({
    super.key,
    required this.selectedColor,
    required this.selectedIcon,
    required this.onColorChanged,
    required this.onIconChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Màu sắc', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: Colors.primaries.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final color = Colors.primaries[index];
              final isSelected = selectedColor.value == color.value;
              return GestureDetector(
                onTap: () => onColorChanged(color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: isSelected ? theme.colorScheme.onSurface : Colors.transparent,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Biểu tượng', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: AppIcons.icons.map((iconData) {
            final isSelected = iconData == selectedIcon;
            return GestureDetector(
              onTap: () => onIconChanged(iconData),
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                    width: 1.6,
                  ),
                ),
                child: Icon(iconData, color: theme.colorScheme.primary, size: 18),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
