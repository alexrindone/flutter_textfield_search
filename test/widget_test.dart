// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_textfield_search/main.dart';

void main() {
  const List dummyList = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5'
  ];
  const String label = 'Test Label';
  const Key testKey = Key('K');
//  final Widget widgetForTest = Scaffold();
  testWidgets('TextFieldSearch has a list and label', (WidgetTester tester) async {
    // Build an app with the TextFieldSearch
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TextFieldSearch(key: testKey, initialList: dummyList, label: label)
      ),
    ));
    // find the TextField by it's type
    var foundTextField = find.byType(TextField);
    // enter some text for the TextField "Item"
    await tester.enterText(foundTextField, 'Item');
    // expect that the widget has focus after entering text
    expect((foundTextField.evaluate().first.widget as TextField).focusNode.hasFocus, true);
    // find the widget by the key
    expect(foundTextField, findsOneWidget);
    // find the widget by the entered text
    expect(find.text('Item'), findsOneWidget);
    // expect that we have one text widget with passed in label: "Test Label"
    expect(find.text(label), findsOneWidget);
    // expect that we have one CompositedTransformFollower
    expect(find.byType(CompositedTransformFollower), findsOneWidget);
    // expect we have one positioned widget
    expect(find.byType(Positioned), findsOneWidget);
    // rebuild widget
    await tester.pumpAndSettle();
    // expect there is a list tile for each item in dummy list (5 total)
    expect(find.byType(ListTile), findsNWidgets(dummyList.length));
    // get all gestures that surround list
    var foundGestures = find.byType(GestureDetector);
    // tap the first gesture which then sets the text field with it's value
    await tester.tap(foundGestures.first);
    // rebuild widget
    await tester.pumpAndSettle();
    // expect that we lost focus since we made a selection for the textfield
    expect((foundTextField.evaluate().first.widget as TextField).focusNode.hasFocus, false);
    // expect that foundTextField's value is the first selection, Item 1
    // since it was selected by the onTap gesture
    expect((foundTextField.evaluate().first.widget as TextField).controller.text, 'Item 1');
    // rebuild widget
    await tester.pumpAndSettle();
    // remove everything from enter text so that list items are removed and empty
    await tester.enterText(foundTextField, '');
    // expect we have no gesture detectors as they should be off screen since
    // textfield is empty
    expect(find.byType(GestureDetector), findsNothing);
    // expect that the textfield's value is blank since we set it to blank string
    expect((foundTextField.evaluate().first.widget as TextField).controller.text, '');
  });
}
