// lib/config/theme/app_theme.dart
import 'package:flutter/material.dart';

/// **Why we used this class (AppColors):**
/// This class acts as a central "palette" for our application. It holds all the specific color codes (Hex values)
/// in one place.
///
/// **How it is helpful:**
/// Instead of hardcoding magic numbers like `Color(0xFF4361EE)` inside every widget, we refer to them by name
/// (e.g., `AppColors.primary`). This makes the code readable and allows us to change the app's entire color scheme
/// by just modifying this one file.
class AppColors {
  // **Primary Colors:**
  // These represent the main brand identity. Used for buttons, app bars, and key UI elements.
  static const Color primary = Color(0xFF4361EE);
  static const Color primaryDark = Color(0xFF3A0CA3);
  static const Color primaryLight = Color(0xFF4CC9F0);

  // **Secondary Colors:**
  // Used for accents, highlights, or secondary actions to add variety.
  static const Color secondary = Color(0xFF7209B7);
  static const Color secondaryLight = Color(0xFFB5179E);

  // **Status Colors:**
  // Standard colors to indicate state: Green for success, Orange for warnings, Red for errors.
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF72585);
  static const Color info = Color(0xFF2196F3);

  // **Neutral Colors:**
  // Used for backgrounds, text, and borders. These are usually shades of white, black, or grey.
  static const Color background = Color(0xFFF8F9FA); // Screen background
  static const Color surface = Color(0xFFFFFFFF); // Card/Sheet background
  static const Color onSurface = Color(0xFF212529); // Text on surface
  static const Color onBackground = Color(0xFF212529); // Text on background
  static const Color outline = Color(0xFFDEE2E6); // Borders and dividers
  static const Color textPrimary = Color(0xFF212529); // Main text
  static const Color textSecondary = Color(0xFF495057); // Subtitles
  static const Color textTertiary = Color(0xFF6C757D); // Hints or disabled text

  static const Color accentColor = Color(0xFF4CC9F0);

  // **Gradients:**
  // Pre-defined gradients for making UI elements look fancy (like the splash screen background).
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );
}

/// **Why we used this class (AppTextStyles):**
/// This class enforces "Typography Consistency". It ensures that all headings, body text,
/// and buttons look the same across different screens.
///
/// **How it works:**
/// We define static `TextStyle` constants here. In our widgets, we just use `AppTextStyles.titleLarge`
/// instead of manually setting font size and weight every time.
class AppTextStyles {
  // **Headers:**
  // Large text for main page titles or hero sections.
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // **Titles:**
  // Medium text for card titles, list headers, or section names.
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // **Body:**
  // Standard text for paragraphs, descriptions, and inputs.
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
  );

  // **Buttons:**
  // Text styles specifically for text inside buttons.
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}

/// **Why we used this class (AppTheme):**
/// This is the master configuration for our Flutter app's visual appearance.
///
/// **What it does:**
/// It creates a `ThemeData` object. When we pass this to our `MaterialApp` (in main.dart),
/// Flutter automatically knows how to style every standard widget (Buttons, TextFields, AppBars)
/// without us needing to style them individually on every screen.
class AppTheme {

  // **Light Theme Configuration:**
  static ThemeData get lightTheme {
    return ThemeData(
      // Use Material 3, which is the latest design system from Google.
      useMaterial3: true,

      // **Color Scheme:**
      // Maps our custom AppColors to Flutter's functional color roles (primary, secondary, error, etc.).
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white, // Text color on top of primary
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // **Text Theme:**
      // Maps our custom AppTextStyles to Flutter's standard text hierarchy.
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineMedium: AppTextStyles.titleLarge,
        headlineSmall: AppTextStyles.titleMedium,
        titleLarge: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
      ),

      // **AppBar Theme:**
      // Sets the default look for the top bar on every screen.
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white, // Color for title and icons
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // **Button Themes:**
      // Defines default shapes, padding, and colors for buttons so they look consistent.

      // 1. ElevatedButton (Solid background)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      // 2. OutlinedButton (Border only)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(color: AppColors.primary),
        ),
      ),

      // 3. TextButton (No border, no background)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextStyles.buttonMedium.copyWith(color: AppColors.primary),
        ),
      ),

      // **Input Decoration Theme (Text Fields):**
      // This is very helpful! It styles all TextFormFields globally.
      // We define border radius, colors for active/inactive states, and padding here.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        // Default border (when not focused)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        // Focused border (when typing) - Thicker and Primary color
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textTertiary),
      ),

      // **Card Theme:**
      // Default style for Card widgets (used in lists and dashboards).
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.surface,
      ),

      // **Dialog Theme:**
      // Styles pop-up alerts.
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),

      // **Progress Indicator Theme:**
      // Sets the color of loading spinners.
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      // **Divider Theme:**
      // Styles the lines separating content.
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // **Dark Theme (Optional/Future):**
  // We can define a dark mode theme here later by overriding specific colors.
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      colorScheme: const ColorScheme.dark().copyWith(
        primary: AppColors.primaryLight,
      ),
    );
  }
}