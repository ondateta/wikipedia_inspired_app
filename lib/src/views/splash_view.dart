import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:template/src/design_system/app_logo.dart';
import 'package:template/src/design_system/app_theme.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const AppLogo(size: 120),
            const Gap(24),
            Text(
              'Local Wikipedia',
              style: theme.textTheme.titleLarge,
            ),
            const Gap(16),
            const CircularProgressIndicator(
              color: AppTheme.primaryLight,
            ),
            const Gap(24),
            Text(
              'Loading...',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}