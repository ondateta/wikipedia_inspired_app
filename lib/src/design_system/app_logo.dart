import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 80,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final darkMode = FlutterLogo(
      size: size,
    );
    final lightMode = FlutterLogo(
      size: size,
    );

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isDarkMode) {
      return darkMode;
    }
    return lightMode;
  }
}