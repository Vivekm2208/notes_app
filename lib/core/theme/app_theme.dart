import 'package:flutter/material.dart';
import 'package:notes_app/core/theme/app_radius.dart';
import 'package:notes_app/core/theme/app_typography.dart';
import 'package:notes_app/core/theme/noted_colors.dart';

class NotedTheme {
  NotedTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,

      scaffoldBackgroundColor: NotedColors.darkBackground,

      colorScheme: const ColorScheme.dark(
        primary: NotedColors.accent,
        surface: NotedColors.darkSurface,
        onSurface: NotedColors.darkTextPrimary,
        surfaceContainerHighest: NotedColors.darkSurfaceVariant,
        outline: NotedColors.darkBorder,
      ),

      textTheme: TextTheme(
        titleMedium: NotedTypography.title.copyWith(
          color: NotedColors.darkTextPrimary,
        ),
        bodyMedium: NotedTypography.body.copyWith(
          color: NotedColors.darkTextSecondary,
        ),
        bodySmall: NotedTypography.caption.copyWith(
          color: NotedColors.darkTextMuted,
        ),
        titleLarge: NotedTypography.appTitle.copyWith(
          color: NotedColors.darkTextPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: NotedColors.darkSurface,
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

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,

      scaffoldBackgroundColor: NotedColors.lightBackground,

      colorScheme: const ColorScheme.light(
        primary: NotedColors.accent,
        surface: NotedColors.lightSurface,
        onSurface: NotedColors.lightTextPrimary,
        surfaceContainerHighest: NotedColors.lightSurfaceVariant,
        outline: NotedColors.lightBorder,
      ),

      textTheme: TextTheme(
        titleMedium: NotedTypography.title.copyWith(
          color: NotedColors.lightTextPrimary,
        ),
        bodyMedium: NotedTypography.body.copyWith(
          color: NotedColors.lightTextSecondary,
        ),
        bodySmall: NotedTypography.caption.copyWith(
          color: NotedColors.lightTextMuted,
        ),
        titleLarge: NotedTypography.appTitle.copyWith(
          color: NotedColors.lightTextPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: NotedColors.lightSurface,
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
