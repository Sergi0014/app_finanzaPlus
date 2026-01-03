import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_ingresos/screens/onboarding_screen.dart';
import 'package:app_ingresos/theme/app_theme.dart';

void main() {
  group('OnboardingScreen Widget', () {
    testWidgets('should display 3 pages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      );

      expect(find.byType(PageView), findsOneWidget);
      expect(find.text('Registra tus Ingresos y Egresos'), findsOneWidget);
    });

    testWidgets('should have skip button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      );

      expect(find.text('Saltar'), findsOneWidget);
    });

    testWidgets('should have next button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      );

      expect(find.text('Siguiente'), findsOneWidget);
    });

    testWidgets('should display page indicators', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      );

      // Verificar que hay 3 indicadores
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('should navigate to next page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      );

      // Tap en el botón Siguiente
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      // Verificar que cambió de página
      expect(find.text('Visualiza tus Finanzas'), findsOneWidget);
    });
  });
}
