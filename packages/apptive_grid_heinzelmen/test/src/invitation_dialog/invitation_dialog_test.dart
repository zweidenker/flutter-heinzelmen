import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:apptive_grid_heinzelmen/src/invitation_dialog/invitation_dialog.dart';
import 'package:apptive_grid_heinzelmen/src/invitation_dialog/invitation_l10n_de.dart';
import 'package:apptive_grid_heinzelmen/src/invitation_dialog/invitation_l10n_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

import '../../infra/mocks.dart';

void main() {
  group('Get Spans', () {
    const style = TextStyle(fontWeight: FontWeight.bold);

    test('Substitute not in result returns single Span', () {
      final spans = getHighlightSpans(
        getText: (_) => 'No Content',
        highlight: 'spaceName',
        highlightStyle: style,
      );

      expect(spans.length, 1);
      expect(spans.first.text, 'No Content');
    });

    test('Substitute is first element returns two Spans', () {
      final spans = getHighlightSpans(
        getText: (value) => '$value Content',
        highlight: 'value',
        highlightStyle: style,
      );

      expect(spans.length, 2);
      expect(spans[0].text, 'value');
      expect(spans[0].style, style);
      expect(spans[1].text, ' Content');
      expect(spans[1].style, isNull);
    });

    test('Substitute is last element returns two Spans', () {
      final spans = getHighlightSpans(
        getText: (value) => 'Content $value',
        highlight: 'value',
        highlightStyle: style,
      );

      expect(spans.length, 2);
      expect(spans[1].text, 'value');
      expect(spans[1].style, style);
      expect(spans[0].text, 'Content ');
      expect(spans[0].style, isNull);
    });

    test('Space Name gets Substituted', () {
      const spaceName = 'spaceName';
      final spans = getHighlightSpans(
        getText: const InvitationLocalizationEn().title,
        highlight: spaceName,
        highlightStyle: style,
      );

      expect(spans.length, 3);
      expect(spans[0].text, 'Share ');
      expect(spans[0].style, isNull);
      expect(spans[1].text, spaceName);
      expect(spans[1].style, style);
      expect(spans[2].text, ' with others');
      expect(spans[2].style, isNull);
    });

    test('Space Name occurs before substitution, is substituted correctly', () {
      const spaceName = 'Share ';
      final spans = getHighlightSpans(
        getText: const InvitationLocalizationEn().title,
        highlight: spaceName,
        highlightStyle: style,
      );

      expect(spans.length, 3);
      expect(spans[0].text, 'Share ');
      expect(spans[0].style, isNull);
      expect(spans[1].text, spaceName);
      expect(spans[1].style, style);
      expect(spans[2].text, ' with others');
      expect(spans[2].style, isNull);
    });

    test('Space Name occurs after substitution, is substituted correctly', () {
      const spaceName = 'others';
      final spans = getHighlightSpans(
        getText: const InvitationLocalizationEn().title,
        highlight: spaceName,
        highlightStyle: style,
      );

      expect(spans.length, 3);
      expect(spans[0].text, 'Share ');
      expect(spans[0].style, isNull);
      expect(spans[1].text, spaceName);
      expect(spans[1].style, style);
      expect(spans[2].text, ' with others');
      expect(spans[2].style, isNull);
    });
  });

  group('Dialog', () {
    late ApptiveGridClient client;

    late BuildContext context;

    late Widget target;

    final inviteLink = ApptiveLink(uri: Uri(path: '/invite'), method: 'post');
    final addShareLink =
        ApptiveLink(uri: Uri(path: '/addShare'), method: 'post');

    const spaceName = 'Space';

    final space = Space(
      id: 'id',
      name: spaceName,
      links: {
        ApptiveLinkType.invite: inviteLink,
        ApptiveLinkType.addShare: addShareLink,
      },
    );

    const email = 'test@apptivegrid.de';

    setUp(() {
      client = MockApptiveGridClient();

      target = ApptiveGrid.withClient(
        client: client,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (buildContext) {
                context = buildContext;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('Show Dialog', (tester) async {
      await tester.pumpWidget(target);
      await tester.pumpAndSettle();

      showSpaceInvitationDialog(context: context, space: space);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Cancel pops dialog', (tester) async {
      await tester.pumpWidget(target);
      await tester.pumpAndSettle();

      showSpaceInvitationDialog(context: context, space: space);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('No email shows error', (tester) async {
      await tester.pumpWidget(target);
      await tester.pumpAndSettle();

      showSpaceInvitationDialog(context: context, space: space);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(find.text('Valid email address necessary'), findsOneWidget);
    });

    testWidgets('Invalid Email shows hint', (tester) async {
      await tester.pumpWidget(target);
      await tester.pumpAndSettle();

      showSpaceInvitationDialog(context: context, space: space);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'invalid@email');

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(find.text('Valid email address necessary'), findsOneWidget);
    });

    testWidgets('Default calls invite', (tester) async {
      when(
        () => client.performApptiveLink<bool>(
          link: inviteLink,
          body: {
            'email': email,
            'role': Role.admin.backendName,
          },
          parseResponse: any(named: 'parseResponse'),
        ),
      ).thenAnswer((invocation) async {
        final parser = invocation.namedArguments[const Symbol('parseResponse')]
            as Future<bool> Function(Response);

        return parser(Response('Invitation send', 200));
      });
      await tester.pumpWidget(target);
      await tester.pumpAndSettle();

      showSpaceInvitationDialog(context: context, space: space);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), email);

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      verify(
        () => client.performApptiveLink<bool>(
          link: inviteLink,
          body: {
            'email': email,
            'role': Role.admin.backendName,
          },
          parseResponse: any(named: 'parseResponse'),
        ),
      ).called(1);
    });

    testWidgets('Success clears field', (tester) async {
      when(
        () => client.performApptiveLink<bool>(
          link: inviteLink,
          body: {
            'email': email,
            'role': Role.admin.backendName,
          },
          parseResponse: any(named: 'parseResponse'),
        ),
      ).thenAnswer((invocation) async {
        final parser = invocation.namedArguments[const Symbol('parseResponse')]
            as Future<bool> Function(Response);

        return parser(Response('Invitation send', 200));
      });
      await tester.pumpWidget(target);
      await tester.pumpAndSettle();

      showSpaceInvitationDialog(context: context, space: space);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), email);

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(find.text(email), findsNothing);
      expect(
        (find.byType(TextFormField).evaluate().first.widget as TextFormField)
            .controller!
            .text,
        equals(''),
      );
    });

    testWidgets('Add Share as type calls add share', (tester) async {
      when(
        () => client.performApptiveLink<bool>(
          link: addShareLink,
          body: {
            'email': email,
            'role': Role.admin.backendName,
          },
          parseResponse: any(named: 'parseResponse'),
        ),
      ).thenAnswer((invocation) async {
        final parser = invocation.namedArguments[const Symbol('parseResponse')]
            as Future<bool> Function(Response);

        return parser(Response('Invitation send', 200));
      });
      await tester.pumpWidget(target);
      await tester.pumpAndSettle();

      showSpaceInvitationDialog(
        context: context,
        space: space,
        type: ApptiveLinkType.addShare,
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), email);

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      verify(
        () => client.performApptiveLink<bool>(
          link: addShareLink,
          body: {
            'email': email,
            'role': Role.admin.backendName,
          },
          parseResponse: any(named: 'parseResponse'),
        ),
      ).called(1);
    });

    group('Result', () {
      testWidgets('Cancel, result is false', (tester) async {
        await tester.pumpWidget(target);
        await tester.pumpAndSettle();

        final result =
            showSpaceInvitationDialog(context: context, space: space);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(await result, isFalse);
      });
      testWidgets('Success, result is true', (tester) async {
        when(
          () => client.performApptiveLink<bool>(
            link: inviteLink,
            body: {
              'email': email,
              'role': Role.admin.backendName,
            },
            parseResponse: any(named: 'parseResponse'),
          ),
        ).thenAnswer((invocation) async {
          final parser =
              invocation.namedArguments[const Symbol('parseResponse')]
                  as Future<bool> Function(Response);

          return parser(Response('Invitation send', 200));
        });
        await tester.pumpWidget(target);
        await tester.pumpAndSettle();

        final result =
            showSpaceInvitationDialog(context: context, space: space);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), email);

        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(await result, isTrue);
      });
    });

    group('Localization', () {
      testWidgets('Locale is German uses German translation', (tester) async {
        await tester.pumpWidget(
          ApptiveGrid.withClient(
            client: client,
            child: MaterialApp(
              locale: const Locale('de'),
              supportedLocales: const [Locale('de')],
              localizationsDelegates: const [
                DefaultWidgetsLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Builder(
                builder: (buildContext) {
                  context = buildContext;
                  return const SizedBox();
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        showSpaceInvitationDialog(context: context, space: space);
        await tester.pumpAndSettle();

        expect(find.text('Senden'), findsOneWidget);
      });
      testWidgets('Override with custom Localization', (tester) async {
        await tester.pumpWidget(target);
        await tester.pumpAndSettle();

        showSpaceInvitationDialog(
          context: context,
          space: space,
          localization: const InvitationLocalizationDE(),
        );
        await tester.pumpAndSettle();

        expect(find.text('Senden'), findsOneWidget);
      });
    });

    group('Error', () {
      testWidgets('Error is shown and keeps field value', (tester) async {
        when(
          () => client.performApptiveLink<bool>(
            link: inviteLink,
            body: {
              'email': email,
              'role': Role.admin.backendName,
            },
            parseResponse: any(named: 'parseResponse'),
          ),
        ).thenAnswer((invocation) async => Future.error('error'));
        await tester.pumpWidget(target);
        await tester.pumpAndSettle();

        showSpaceInvitationDialog(context: context, space: space);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), email);

        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();

        expect(find.text(email), findsOneWidget);
        expect(find.text('error'), findsOneWidget);
        expect(
          (find.byType(TextFormField).evaluate().first.widget as TextFormField)
              .controller!
              .text,
          equals(email),
        );
      });

      testWidgets('Error Body has description shows error', (tester) async {
        when(
          () => client.performApptiveLink<bool>(
            link: inviteLink,
            body: {
              'email': email,
              'role': Role.admin.backendName,
            },
            parseResponse: any(named: 'parseResponse'),
          ),
        ).thenAnswer(
          (invocation) async => Future.error(
            Response(
              '''{
      "error" : "emailNotfound",
      "description" : "User with email '$email' does not exist."
      }''',
              400,
            ),
          ),
        );
        await tester.pumpWidget(target);
        await tester.pumpAndSettle();

        showSpaceInvitationDialog(context: context, space: space);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), email);

        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();

        expect(find.text(email), findsOneWidget);
        expect(
          find.text("User with email '$email' does not exist."),
          findsOneWidget,
        );
        expect(
          (find.byType(TextFormField).evaluate().first.widget as TextFormField)
              .controller!
              .text,
          equals(email),
        );
      });

      testWidgets('Body Parsing fails shows response', (tester) async {
        when(
          () => client.performApptiveLink<bool>(
            link: inviteLink,
            body: {
              'email': email,
              'role': Role.admin.backendName,
            },
            parseResponse: any(named: 'parseResponse'),
          ),
        ).thenAnswer(
          (invocation) async => Future.error(Response('''{''', 400)),
        );
        await tester.pumpWidget(target);
        await tester.pumpAndSettle();

        showSpaceInvitationDialog(context: context, space: space);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), email);

        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();

        expect(find.text(email), findsOneWidget);
        expect(find.text("Instance of 'Response'"), findsOneWidget);
        expect(
          (find.byType(TextFormField).evaluate().first.widget as TextFormField)
              .controller!
              .text,
          equals(email),
        );
      });

      testWidgets('Error Body has no description shows body', (tester) async {
        when(
          () => client.performApptiveLink<bool>(
            link: inviteLink,
            body: {
              'email': email,
              'role': Role.admin.backendName,
            },
            parseResponse: any(named: 'parseResponse'),
          ),
        ).thenAnswer(
          (invocation) async => Future.error(Response('"body"', 400)),
        );
        await tester.pumpWidget(target);
        await tester.pumpAndSettle();

        showSpaceInvitationDialog(context: context, space: space);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), email);

        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();

        expect(find.text(email), findsOneWidget);
        expect(find.text('body'), findsOneWidget);
        expect(
          (find.byType(TextFormField).evaluate().first.widget as TextFormField)
              .controller!
              .text,
          equals(email),
        );
      });
    });

    group('Roles', () {
      testWidgets('Change Role is applied', (tester) async {
        when(
          () => client.performApptiveLink<bool>(
            link: inviteLink,
            body: any(named: 'body'),
            parseResponse: any(named: 'parseResponse'),
          ),
        ).thenAnswer((invocation) async {
          final parser =
              invocation.namedArguments[const Symbol('parseResponse')]
                  as Future<bool> Function(Response);

          return parser(Response('Invitation send', 200));
        });
        await tester.pumpWidget(target);
        await tester.pumpAndSettle();

        showSpaceInvitationDialog(context: context, space: space);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), email);

        await tester.tap(find.text('Manage'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Read only').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), email);

        await tester.tap(find.text('Read only'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Edit entries').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();

        verify(
          () => client.performApptiveLink<bool>(
            link: inviteLink,
            body: {
              'email': email,
              'role': Role.writer.backendName,
            },
            parseResponse: any(named: 'parseResponse'),
          ),
        ).called(1);

        verify(
          () => client.performApptiveLink<bool>(
            link: inviteLink,
            body: {
              'email': email,
              'role': Role.reader.backendName,
            },
            parseResponse: any(named: 'parseResponse'),
          ),
        ).called(1);
      });

      testWidgets('Success keeps selected role', (tester) async {
        when(
          () => client.performApptiveLink<bool>(
            link: inviteLink,
            body: any(named: 'body'),
            parseResponse: any(named: 'parseResponse'),
          ),
        ).thenAnswer((invocation) async {
          final parser =
              invocation.namedArguments[const Symbol('parseResponse')]
                  as Future<bool> Function(Response);

          return parser(Response('Invitation send', 200));
        });
        await tester.pumpWidget(target);
        await tester.pumpAndSettle();

        showSpaceInvitationDialog(context: context, space: space);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), email);

        await tester.tap(find.text('Manage'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Read only').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();

        expect(find.text('Read only'), findsOneWidget);
      });

      testWidgets('Only allows defined roles', (tester) async {
        await tester.pumpWidget(target);
        await tester.pumpAndSettle();

        showSpaceInvitationDialog(
          context: context,
          space: space,
          allowedRoles: [
            Role.reader,
            Role.writer,
          ],
        );
        await tester.pumpAndSettle();

        expect(find.text('Read only'), findsOneWidget);
        await tester.tap(find.text('Read only'));
        await tester.pumpAndSettle();
        expect(find.text('Manage'), findsNothing);
        // 2 For Selected Builder and Items
        expect(find.text('Read only'), findsNWidgets(2));
        expect(find.text('Edit entries'), findsNWidgets(1));
        expect(
          (find.byType(DropdownButton<Role>).evaluate().first.widget
                  as DropdownButton)
              .items!
              .length,
          2,
        );
      });

      testWidgets('Only one allowed role hides selection', (tester) async {
        when(
          () => client.performApptiveLink<bool>(
            link: inviteLink,
            body: any(named: 'body'),
            parseResponse: any(named: 'parseResponse'),
          ),
        ).thenAnswer((invocation) async {
          final parser =
              invocation.namedArguments[const Symbol('parseResponse')]
                  as Future<bool> Function(Response);

          return parser(Response('Invitation send', 200));
        });
        await tester.pumpWidget(target);
        await tester.pumpAndSettle();

        showSpaceInvitationDialog(
          context: context,
          space: space,
          allowedRoles: [
            Role.admin,
          ],
        );
        await tester.pumpAndSettle();

        expect(find.byType(DropdownButton<Role>), findsNothing);

        await tester.enterText(find.byType(TextFormField), email);

        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();

        verify(
          () => client.performApptiveLink<bool>(
            link: inviteLink,
            body: {
              'email': email,
              'role': Role.admin.backendName,
            },
            parseResponse: any(named: 'parseResponse'),
          ),
        ).called(1);
      });
    });
  });
}
