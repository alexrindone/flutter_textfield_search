import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:textfield_search/textfield_search.dart';
import 'dart:async';

void main() {
  testWidgets('TextFieldSearch has a list and label', (WidgetTester tester) async {
    const List dummyList = [
      'Item 1',
      'Item 2',
      'Item 3',
      'Item 4',
      'Item 5'
    ];
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();
    // Build an app with the TextFieldSearch
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TextFieldSearch(key: testKey, initialList: dummyList, label: label, controller: myController,)
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
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
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
    await tester.enterText(foundTextField, 'Item 6');
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    expect(find.text('No matching items'), findsOneWidget);
    var foundConstrainedBox = find.byType(ConstrainedBox);
    // Constrained Box constraints are infinity when running tests and goes off of biggest
    expect((foundConstrainedBox.evaluate().first.widget as ConstrainedBox).constraints.biggest, BoxConstraints().biggest);
    expect((tester.getSize(find.text('No matching items'))), Size(768, 16.0));
    expect((tester.getSize(foundConstrainedBox.first)), Size(800, 600.0));
    await tester.enterText(find.text('Item 6'), '');
    expect((find.byType(TextField).evaluate().first.widget as TextField).controller.text.isEmpty, true);
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
  });

  testWidgets('TextFieldSearch has a future that returns a List', (WidgetTester tester) async {
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();

    // mocking a future that takes 1000ms to resolve
    Future<List> fetchData() async {
      await Future.delayed(Duration(milliseconds: 5000));
      List _list = new List();
      String _inputText = myController.text;
      // create a list from the text input of three items
      // to mock a list of items from an http call
      _list.add(_inputText + ' Item 1');
      _list.add(_inputText + ' Item 2');
      _list.add(_inputText + ' Item 3');
      return _list;
    }
    // Build an app with the TextFieldSearch
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: TextFieldSearch(
            key: testKey,
            label: label,
            controller: myController,
            future: () {
              return fetchData();
            },
          )
      ),
    ));

    // find the TextField by it's type
    var foundTextField = find.byType(TextField);
    // enter some text for the TextField "Test"
    await tester.enterText(foundTextField, 'Test');
    expect((foundTextField.evaluate().first.widget as TextField).controller.text, 'Test');
    // test for loading indicator
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    // expect that we have one CompositedTransformFollower
    expect(find.byType(CompositedTransformFollower), findsOneWidget);
    // expect we have one positioned widget
    expect(find.byType(Positioned), findsOneWidget);
    await tester.pumpAndSettle(Duration(milliseconds: 2000));
    // find the widget by the key
    expect(foundTextField, findsOneWidget);
    // expect there is a list tile for each item in dummy list (3 total)
    // which the future created
    expect(find.byType(ListTile), findsNWidgets(3));
    // expect the value for each value in future list
    expect(find.text('Test Item 1'), findsOneWidget);
    expect(find.text('Test Item 2'), findsOneWidget);
    expect(find.text('Test Item 3'), findsOneWidget);
  });

  testWidgets('TextFieldSearch has a future that returns no items', (WidgetTester tester) async {
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();

    // mocking a future that takes 1000ms to resolve
    Future<List> fetchData() async {
      await Future.delayed(Duration(milliseconds: 3000));
      List _list = new List();
      // create a list that returns no results
      // to mock a list of items from an http call
      return _list;
    }
    // Build an app with the TextFieldSearch
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: TextFieldSearch(
            key: testKey,
            label: label,
            controller: myController,
            future: () {
              return fetchData();
            },
          )
      ),
    ));

    // find the TextField by it's type
    var foundTextField = find.byType(TextField);
    // enter some text for the TextField "Test"
    await tester.enterText(foundTextField, 'Test');
    expect((foundTextField.evaluate().first.widget as TextField).controller.text, 'Test');
    // test for loading indicator
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    // expect that we have one CompositedTransformFollower
    expect(find.byType(CompositedTransformFollower), findsOneWidget);
    // expect we have one positioned widget
    expect(find.byType(Positioned), findsOneWidget);
    await tester.pumpAndSettle(Duration(milliseconds: 2000));
    // find the widget by the key
    expect(foundTextField, findsOneWidget);
    // expect there is a list tile for each item in dummy list (3 total)
    // which the future created
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('No matching items'), findsOneWidget);
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    // remove everything from enter text so that list items are removed and empty
    await tester.enterText(foundTextField, '');
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    expect(find.byType(ListTile), findsNothing);

  });

  testWidgets('TextFieldSearch has getSelectedValue', (WidgetTester tester) async {
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();
    dynamic selectedItem;
    // mocking a future that returns List of Objects
    Future<List> fetchData() async {
      await Future.delayed(Duration(milliseconds: 3000));
      List _list = new List();
      String _inputText = myController.text;
      List _jsonList = [
        {'label': _inputText + ' Item 1', 'value': 30},
        {'label': _inputText + ' Item 2', 'value': 31},
        {'label': _inputText + ' Item 3', 'value': 32},
      ];
      // create a list from the text input of three items
      // to mock a list of items from an http call where
      // the label is what is seen in the textfield and something like an
      // ID is the selected value
      _list.add(new TestItem.fromJson(_jsonList[0]));
      _list.add(new TestItem.fromJson(_jsonList[1]));
      _list.add(new TestItem.fromJson(_jsonList[2]));

      return _list;
    }

    // Build an app with the TextFieldSearch
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: TextFieldSearch(
            key: testKey,
            label: label,
            controller: myController,
            future: () {
              return fetchData();
            },
            getSelectedValue: (item) {
              selectedItem = item.value;
            },
          )
      ),
    ));

    // find the TextField by it's type
    var foundTextField = find.byType(TextField);
    // enter some text for the TextField "Test"
    await tester.enterText(foundTextField, 'Test');
    expect((foundTextField.evaluate().first.widget as TextField).controller.text, 'Test');
    // test for loading indicator
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    // expect that we have one CompositedTransformFollower
    expect(find.byType(CompositedTransformFollower), findsOneWidget);
    // expect we have one positioned widget
    expect(find.byType(Positioned), findsOneWidget);
    await tester.pumpAndSettle(Duration(milliseconds: 2000));
    // find the widget by the key
    expect(foundTextField, findsOneWidget);
    // expect there is a list tile for each item in dummy list (3 total)
    // which the future created
    expect(find.byType(ListTile), findsNWidgets(3));
    // expect the value for each value in future list
    expect(find.text('Test Item 1'), findsOneWidget);
    expect(find.text('Test Item 2'), findsOneWidget);
    expect(find.text('Test Item 3'), findsOneWidget);
    var foundGestures = find.byType(GestureDetector);
    // tap the first gesture which then sets the text field with it's value
    await tester.tap(foundGestures.first);
    // rebuild widget
    await tester.pumpAndSettle();
    expect(selectedItem, 30);
  });

  test('Debouncer executes function only once despite repeated calls', () async {
    // test that debouncer waits for 1000ms before calling function
    Debouncer _debouncer = Debouncer(milliseconds: 1000);
    // expect that the value we pass for milliseconds is the same
    expect(_debouncer.milliseconds, 1000);
    // empty list to add an Item to
    List _testList = List();
    // function to attempt to call multiple times that adds an item to a list
    void testFn() {
      _testList.add('Item');
    }
    // call the function immediately
    _debouncer.run(() => testFn());
    // since debounce is after 1000ms, the testList should still be empty
    expect(_testList.length, 0);

    // Call the function several times with 500ms between each call
    for(var i = 0; i < 10; i++) {
      await Future.delayed(Duration(milliseconds: 500));
      _debouncer.run(() => testFn());
    }
    // wait 1000ms so the last function call for debounce occurs
    await Future.delayed(Duration(milliseconds: 1000));
    // since the function executed, list should have one item in it
    expect(_testList.length, 1); // func called
    expect(_testList[0], 'Item');
  });

}

class TestItem {
  String label;
  dynamic value;
  TestItem({
    this.label,
    this.value
  });

  factory TestItem.fromJson(Map<String, dynamic> json) {
    return TestItem(
        label: json['label'],
        value: json['value']
    );
  }
}
