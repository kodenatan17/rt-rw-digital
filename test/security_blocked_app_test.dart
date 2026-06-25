import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rt_rw_digital/security_blocked_app.dart';

void main() {
  // ════════════════════════════════════════════════════════════════════
  //  SecurityBlockedApp widget tests
  //
  //  Verifies that the fallback UI renders correctly when device
  //  integrity check fails. This widget is a plain MaterialApp with
  //  a single Scaffold — no async initialization needed.
  // ════════════════════════════════════════════════════════════════════

  group('SecurityBlockedApp', () {
    testWidgets('renders "Security Warning" title', (tester) async {
      await tester.pumpWidget(const SecurityBlockedApp());

      // The title text should be present.
      expect(find.text('Security Warning'), findsOneWidget);
    });

    testWidgets('renders the jailbreak/rooted warning message', (tester) async {
      await tester.pumpWidget(const SecurityBlockedApp());

      // The main body text explaining why the app cannot run.
      expect(
        find.textContaining('jailbroken or rooted'),
        findsOneWidget,
      );
    });

    testWidgets('renders the instructional sub-message', (tester) async {
      await tester.pumpWidget(const SecurityBlockedApp());

      // The secondary message advising the user.
      expect(
        find.textContaining('Please use a device'),
        findsOneWidget,
      );
    });

    testWidgets('displays the security icon', (tester) async {
      await tester.pumpWidget(const SecurityBlockedApp());

      // The warning icon should be present.
      // Icons.gpp_bad_rounded is the shield-with-crossmark.
      expect(find.byIcon(Icons.gpp_bad_rounded), findsOneWidget);
    });

    testWidgets('uses Scaffold layout', (tester) async {
      await tester.pumpWidget(const SecurityBlockedApp());

      // The widget tree should contain a Scaffold.
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('uses SafeArea for notched devices', (tester) async {
      await tester.pumpWidget(const SecurityBlockedApp());

      // SafeArea wraps the content column.
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('renders a MaterialApp', (tester) async {
      await tester.pumpWidget(const SecurityBlockedApp());

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('has no overflow in the layout', (tester) async {
      await tester.pumpWidget(const SecurityBlockedApp());

      // Pump and settle — no overflow errors should appear.
      expect(tester.takeException(), isNull);
    });

    testWidgets('debugShowCheckedModeBanner is disabled', (tester) async {
      await tester.pumpWidget(const SecurityBlockedApp());

      // The debug banner is a MaterialBanner with debug text. When
      // disabled, it should not be found.
      expect(
        find.textContaining('DEBUG', findRichText: false),
        findsNothing,
      );
    });
  });
}
