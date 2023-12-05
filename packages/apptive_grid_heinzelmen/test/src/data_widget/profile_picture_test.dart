import 'package:apptive_grid_heinzelmen/src/data_widget/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Error Shows Initials', (tester) async {
    const target = MaterialApp(
      home: SizedBox(
        width: 70,
        height: 70,
        child: ProfilePicture(userId: 'userId', name: 'First Last'),
      ),
    );

    await tester.pumpWidget(target);
    await tester.pumpAndSettle();

    expect(find.text('FL'), findsOneWidget);
  });

  group('Ignore No Profile Picture Error', () {
    const codeToIgnore = 403;
    const hostToIgnore =
        'apptiveavatarupload-apptiveavataruploadbucket-17hw58ak4gvs6.s3.eu-central-1.amazonaws.com';
    test('403 with host gets ignored', () async {
      final exception = NetworkImageLoadException(
        statusCode: codeToIgnore,
        uri: Uri(host: hostToIgnore),
      );

      expect(ignoreNoProfilePictureError(exception), isTrue);
    });

    test('Different status code is not ignored', () async {
      final exception = NetworkImageLoadException(
        statusCode: codeToIgnore + 1,
        uri: Uri(host: hostToIgnore),
      );

      expect(ignoreNoProfilePictureError(exception), isFalse);
    });

    test('Different host is not ignored', () async {
      final exception = NetworkImageLoadException(
        statusCode: codeToIgnore,
        uri: Uri(host: 'different'),
      );

      expect(ignoreNoProfilePictureError(exception), isFalse);
    });
  });
}
