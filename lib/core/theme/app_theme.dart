import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// CricLive Material 3 theme configuration — WCAG AA compliant.
///
/// Dark-first theme with layered surface depth.
abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: AppColors.darkColorScheme,
        textTheme: AppTypography.textTheme,
        scaffoldBackgroundColor: AppColors.background,

        // ─── AppBar ────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: AppTypography.headlineLarge,
          systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: AppColors.navBarBackground,
          ),
        ),

        // ─── Card (elevated depth) ─────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.border, width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
        ),

        // ─── Elevated Button ───────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textOnAccent,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // ─── Navigation Bar (Bottom) ──────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          height: 64,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.secondary.withValues(alpha: 0.15),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: AppColors.navBarSelected,
                size: 24,
              );
            }
            return const IconThemeData(
              color: AppColors.navBarUnselected,
              size: 24,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTypography.labelSmall.copyWith(
                color: AppColors.navBarSelected,
                fontWeight: FontWeight.w600,
              );
            }
            return AppTypography.labelSmall.copyWith(
              color: AppColors.navBarUnselected,
            );
          }),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),

        // ─── Divider ──────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 0.5,
          space: 0,
        ),

        // ─── Tab Bar ──────────────────────────────────────
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.secondary,
          labelStyle: AppTypography.labelLarge,
          unselectedLabelStyle: AppTypography.labelMedium,
          dividerColor: AppColors.border,
          indicatorSize: TabBarIndicatorSize.label,
        ),

        // ─── Chip ─────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.elevated,
          labelStyle: AppTypography.labelMedium,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),

        // ─── Bottom Sheet ─────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),

        // ─── Snackbar ─────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.elevated,
          contentTextStyle: AppTypography.bodyMedium,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}
