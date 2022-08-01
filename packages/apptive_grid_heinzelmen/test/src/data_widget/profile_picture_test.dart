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
}
