import 'package:fluent_ui/fluent_ui.dart';

class AppTheme {
  static FluentThemeData darkTheme() {
    return FluentThemeData(
      brightness: Brightness.dark,
      accentColor: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      navigationPaneTheme: const NavigationPaneThemeData(
        backgroundColor: Color(0xFF1A1A1A),
      ),
    );
  }

  static FluentThemeData lightTheme() {
    return FluentThemeData(
      brightness: Brightness.light,
      accentColor: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      navigationPaneTheme: const NavigationPaneThemeData(
        backgroundColor: Color(0xFFFFFFFF),
      ),
    );
  }

  static const Color glassBackground = Color(0x30FFFFFF);
  static const Color glassBorder = Color(0x50FFFFFF);
  static const Color primaryGradientStart = Color(0xFF4A90E2);
  static const Color primaryGradientEnd = Color(0xFF357ABD);
  static const Color connectedGreen = Color(0xFF4CAF50);
  static const Color disconnectedRed = Color(0xFFE53935);
  static const Color warningOrange = Color(0xFFFF9800);

  static BoxDecoration glassDecoration({
    double borderRadius = 16,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: Colors.white.withOpacity(opacity),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ],
    );
  }

  static BoxDecoration gradientButtonDecoration({
    double borderRadius = 12,
    bool isActive = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        colors: isActive
            ? [connectedGreen, connectedGreen.withOpacity(0.7)]
            : [primaryGradientStart, primaryGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: (isActive ? connectedGreen : primaryGradientStart).withOpacity(0.4),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static Color getPingColor(int? ping) {
    if (ping == null || ping < 0) return Colors.grey;
    if (ping < 100) return connectedGreen;
    if (ping < 300) return warningOrange;
    return disconnectedRed;
  }

  static String formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '$bytesPerSecond B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

