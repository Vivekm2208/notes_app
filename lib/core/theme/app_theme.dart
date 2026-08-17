import 'package:flutter/material.dart';
import 'package:notes_app/core/theme/app_radius.dart';
import 'package:notes_app/core/theme/app_typography.dart';
import 'package:notes_app/core/theme/noted_colors.dart';

class NotedTheme {
  NotedTheme._();

  static ThemeData get dark {
    return ThemeData(
      scaffoldBackgroundColor: NotedColors.background,
      colorScheme: const ColorScheme.dark(
        primary: NotedColors.accent,
        surface: NotedColors.surface,
        onSurface: NotedColors.textPrimary,
        surfaceContainerHighest: NotedColors.surfaceVariant,
        outline: NotedColors.border,
      ),

      textTheme: TextTheme(
        titleMedium: NotedTypography.title.copyWith(
          color: NotedColors.textPrimary,
        ),
        bodyMedium: NotedTypography.body.copyWith(
          color: NotedColors.textSecondary,
        ),
        bodySmall: NotedTypography.caption.copyWith(
          color: NotedColors.textMuted,
        ),
        titleLarge: NotedTypography.appTitle.copyWith(
          color: NotedColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: NotedColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NotedRadius.xs),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
