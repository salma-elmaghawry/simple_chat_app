import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_chat_app/app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SimpleChatApp());
    await tester.pumpAndSettle();
  }

  Future<void> goToLogin(WidgetTester tester) async {
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
  }

  testWidgets('starts on the intro screen', (tester) async {
    await pumpApp(tester);

    expect(find.text('Get Closer To EveryOne'), findsOneWidget);
    expect(
      find.text('Helps you to contact everyone with just easy way'),
      findsOneWidget,
    );
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Get Started opens login, which links to sign up and back', (
    tester,
  ) async {
    await pumpApp(tester);

    await goToLogin(tester);
    expect(find.text('Hello, Welcome Back'), findsOneWidget);
    expect(find.text('Forgot Password'), findsOneWidget);
    expect(find.text('Or Login with'), findsOneWidget);

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Let’s Get Started'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Welcome Back'), findsOneWidget);
  });

  testWidgets('submitting an empty login form shows validation errors', (
    tester,
  ) async {
    await pumpApp(tester);
    await goToLogin(tester);

    await tester.tap(find.widgetWithText(Center, 'Login').first);
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('the eye icon reveals and hides the password', (tester) async {
    await pumpApp(tester);
    await goToLogin(tester);

    TextField passwordField() =>
        tester.widget<TextField>(find.byType(TextField).last);

    expect(passwordField().obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(passwordField().obscureText, isFalse);
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(passwordField().obscureText, isTrue);
  });

  testWidgets('an unknown route shows the not-found page', (
    tester,
  ) async {
    await pumpApp(tester);

    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed('/does-not-exist');
    await tester.pumpAndSettle();

    expect(find.text('Page not found'), findsOneWidget);
  });
}
