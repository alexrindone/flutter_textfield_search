import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:textfield_search/textfield_search.dart';

void main() {
  testWidgets('TextFieldSearch has a list and label',
      (WidgetTester tester) async {
    const List dummyList = ['Item 1', 'Item 2'];
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();
    // Build an app with the TextFieldSearch
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: TextFieldSearch(
        key: testKey,
        initialList: dummyList,
        label: label,
        controller: myController,
      )),
    ));
    // find the TextField by it's type
    var foundTextField = find.byType(TextField);
    // enter some text for the TextField "Item"
    await tester.enterText(foundTextField, 'Item');
    // expect that the widget has focus after entering text
    expect(
        (foundTextField.evaluate().first.widget as TextField)
            .focusNode
            ?.hasFocus,
        true);
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
    expect(
        (foundTextField.evaluate().first.widget as TextField)
            .focusNode
            ?.hasFocus,
        false);
    // expect that foundTextField's value is the first selection, Item 1
    // since it was selected by the onTap gesture
    expect(
        (foundTextField.evaluate().first.widget as TextField).controller?.text,
        'Item 1');
    // rebuild widget
    await tester.pumpAndSettle();
    // remove everything from enter text so that list items are removed and empty
    await tester.enterText(foundTextField, '');
    // expect we have no gesture detectors as they should be off screen since
    // textfield is empty
    expect(find.byType(GestureDetector), findsNothing);
    // expect that the textfield's value is blank since we set it to blank string
    expect(
        (foundTextField.evaluate().first.widget as TextField).controller?.text,
        '');
    await tester.enterText(foundTextField, 'Item 3');
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    var foundConstrainedBox = find.byType(ConstrainedBox);
    // Constrained Box constraints are infinity when running tests and goes off of biggest
    expect(
        (foundConstrainedBox.evaluate().first.widget as ConstrainedBox)
            .constraints
            .biggest,
        BoxConstraints().biggest);
    expect((tester.getSize(foundConstrainedBox.first)), Size(800, 600.0));
    expect(find.byType(ListTile, skipOffstage: false), findsOneWidget);
    expect(find.text('No matching items.'), findsOneWidget);
    await tester.enterText(find.text('Item 3'), '');
    expect(
        (find.byType(TextField).evaluate().first.widget as TextField)
            .controller
            ?.text
            .isEmpty,
        true);
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
  });

  testWidgets('TextFieldSearch has a future that returns a List',
      (WidgetTester tester) async {
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();

    // mocking a future that takes 1000ms to resolve
    Future<List> fetchData() async {
      await Future.delayed(Duration(milliseconds: 5000));
      List _list = <dynamic>[];
      String _inputText = myController.text;
      // create a list from the text input of three items
      // to mock a list of items from an http call
      _list.add(_inputText + ' Item 1');
      _list.add(_inputText + ' Item 2');
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
      )),
    ));

    // find the TextField by it's type
    var foundTextField = find.byType(TextField);
    // enter some text for the TextField "Test"
    await tester.enterText(foundTextField, 'Test');
    expect(
        (foundTextField.evaluate().first.widget as TextField).controller?.text,
        'Test');
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
    expect(find.byType(ListTile), findsNWidgets(2));
    // expect the value for each value in future list
    expect(find.text('Test Item 1'), findsOneWidget);
    expect(find.text('Test Item 2'), findsOneWidget);
  });

  testWidgets('TextFieldSearch has a future that returns no items',
      (WidgetTester tester) async {
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();

    // mocking a future that takes 1000ms to resolve
    Future<List> fetchData() async {
      await Future.delayed(Duration(milliseconds: 3000));
      List _list = <dynamic>[];
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
      )),
    ));

    // find the TextField by it's type
    var foundTextField = find.byType(TextField);
    // enter some text for the TextField "Test"
    await tester.enterText(foundTextField, 'Test');
    expect(
        (foundTextField.evaluate().first.widget as TextField).controller?.text,
        'Test');
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
    expect(find.byType(ListTile, skipOffstage: false), findsOneWidget);
    expect(find.text('No matching items.'), findsOneWidget);
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    // remove everything from enter text so that list items are removed and empty
    await tester.enterText(foundTextField, '');
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('TextFieldSearch has getSelectedValue',
      (WidgetTester tester) async {
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();
    dynamic selectedItem;
    // mocking a future that returns List of Objects
    Future<List> fetchData() async {
      await Future.delayed(Duration(milliseconds: 3000));
      List _list = <dynamic>[];
      String _inputText = myController.text;
      List _jsonList = [
        {'label': _inputText + ' Item 1', 'value': 30},
        {'label': _inputText + ' Item 2', 'value': 31},
      ];
      // create a list from the text input of three items
      // to mock a list of items from an http call where
      // the label is what is seen in the textfield and something like an
      // ID is the selected value
      _list.add(new TestItem.fromJson(_jsonList[0]));
      _list.add(new TestItem.fromJson(_jsonList[1]));

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
      )),
    ));

    // find the TextField by it's type
    var foundTextField = find.byType(TextField);
    // enter some text for the TextField "Test"
    await tester.enterText(foundTextField, 'Test');
    expect(
        (foundTextField.evaluate().first.widget as TextField).controller?.text,
        'Test');
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
    expect(find.byType(ListTile), findsNWidgets(2));
    // expect the value for each value in future list
    expect(find.text('Test Item 1'), findsOneWidget);
    expect(find.text('Test Item 2'), findsOneWidget);
    var foundGestures = find.byType(GestureDetector);
    // tap the first gesture which then sets the text field with it's value
    await tester.tap(foundGestures.first);
    // rebuild widget
    await tester.pumpAndSettle();
    expect(selectedItem, 30);
  });

  testWidgets('Tap `No matching items` clears search input',
      (WidgetTester tester) async {
    // Enter text code...
    const List dummyList = ['Item 1', 'Item 2'];
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();
    // Build an app with the TextFieldSearch
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: TextFieldSearch(
        key: testKey,
        initialList: dummyList,
        label: label,
        controller: myController,
      )),
    ));

    await tester.enterText(find.byType(TextField), 'Test');
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    // Expect that we have a TextField with a value equal to what we entered, and we know will show 'No matching items.'
    TextField text =
        find.byType(TextField).evaluate().first.widget as TextField;
    expect(text.controller?.text, 'Test');

    // Rebuild the widget after the state has changed.
    await tester.pumpAndSettle(Duration(milliseconds: 1000));

    // Tap the not items found button
    await tester.tap(find.text('No matching items.'));
    text = find.byType(TextField).evaluate().first.widget as TextField;
    // Expect to find controller is cleared and set to an empty string
    expect(text.controller?.text, '');
  });

  testWidgets(
      'Submit on keyboard when input doesn\'t match list item exactly clears input',
      (WidgetTester tester) async {
    // Enter text code...
    const List dummyList = ['Item 1', 'Item 2'];
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();
    // Build an app with the TextFieldSearch
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: TextFieldSearch(
        key: testKey,
        initialList: dummyList,
        label: label,
        controller: myController,
      )),
    ));

    await tester.enterText(find.byType(TextField), 'Item');
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    // Expect that we have a TextField with a value equal to what we entered, and we know will show 'No matching items.'
    TextField text =
        find.byType(TextField).evaluate().first.widget as TextField;
    expect(text.controller?.text, 'Item');

    // Rebuild the widget after the state has changed.
    await tester.pumpAndSettle(Duration(milliseconds: 1000));

    // Tap the submit button on the keyboard
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle(Duration(milliseconds: 1000));

    text = find.byType(TextField).evaluate().first.widget as TextField;
    // Expect to find controller is cleared and set to an empty string
    expect(text.controller?.text, '');
  });

  testWidgets(
      'Input clears when TextFieldSearch has getSelectedValue with label that doesn\'t match input',
      (WidgetTester tester) async {
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();
    // mocking a future that returns List of Objects
    Future<List> fetchData() async {
      await Future.delayed(Duration(milliseconds: 3000));
      List _list = <dynamic>[];
      List _jsonList = [
        {'label': 'Test Item 1', 'value': 30},
        {'label': 'Test Item 2', 'value': 31},
      ];
      // create a list from the text input of three items
      // to mock a list of items from an http call where
      // the label is what is seen in the textfield and something like an
      // ID is the selected value
      _list.add(new TestItem.fromJson(_jsonList[0]));
      _list.add(new TestItem.fromJson(_jsonList[1]));

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
          print(item);
        },
      )),
    ));

    // find the TextField by it's type
    var foundTextField = find.byType(TextField);
    // enter some text for the TextField "Test"
    await tester.enterText(foundTextField, 'Test Item');
    TextField text = foundTextField.evaluate().first.widget as TextField;
    expect(text.controller?.text, 'Test Item');
    // Rebuild the widget after the state has changed.
    await tester.pumpAndSettle(Duration(milliseconds: 1000));

    // Tap the submit button on the keyboard
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle(Duration(milliseconds: 1000));

    text = find.byType(TextField).evaluate().first.widget as TextField;
    // Expect to find controller is cleared and set to an empty string
    expect(text.controller?.text, '');
  });

  testWidgets('TextFieldSearch can have a custom scollbar theme',
      (WidgetTester tester) async {
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();

    // mocking a future that takes 1000ms to resolve
    Future<List> fetchData() async {
      await Future.delayed(Duration(milliseconds: 2000));
      List _list = <dynamic>[];
      String _inputText = myController.text;
      // create a list from the text input of three items
      // to mock a list of items from an http call
      _list.add(_inputText + ' Item 1');
      _list.add(_inputText + ' Item 2');
      return _list;
    }

    // Build an app with the TextFieldSearch
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: TextFieldSearch(
        key: testKey,
        label: label,
        scrollbarDecoration: ScrollbarDecoration(
            controller: ScrollController(),
            theme: ScrollbarThemeData(
                isAlwaysShown: true,
                thickness: MaterialStateProperty.all(10.0))),
        controller: myController,
        future: () {
          return fetchData();
        },
      )),
    ));

    // find the TextField by it's type
    var foundTextField = find.byType(TextField);
    // enter some text for the TextField "Test"
    await tester.enterText(foundTextField, 'Test');
    expect(
        (foundTextField.evaluate().first.widget as TextField).controller?.text,
        'Test');

    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    // expect that we have a Scrollbar
    expect(find.byType(Scrollbar), findsOneWidget);
    // height of 110 because there are two items found
    expect(tester.getSize(find.byType(Scrollbar)), Size(800.0, 110.0));
    // make sure we have two items found
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets(
      'TextFieldSearch will have scrollbar with default height of 3 items if more results than height are found',
      (WidgetTester tester) async {
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();

    // mocking a future that takes 1000ms to resolve
    Future<List> fetchData() async {
      await Future.delayed(Duration(milliseconds: 2000));
      List _list = <dynamic>[];
      String _inputText = myController.text;
      // create a list from the text input of three items
      // to mock a list of items from an http call
      for (var i = 0; i <= 10; i++) {
        _list.add(_inputText + ' Item ' + i.toString());
      }

      return _list;
    }

    // Build an app with the TextFieldSearch
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: TextFieldSearch(
        key: testKey,
        label: label,
        scrollbarDecoration: ScrollbarDecoration(
            controller: ScrollController(),
            theme: ScrollbarThemeData(
                isAlwaysShown: true,
                thickness: MaterialStateProperty.all(10.0))),
        controller: myController,
        future: () {
          return fetchData();
        },
      )),
    ));

    // find the TextField by it's type
    var foundTextField = find.byType(TextField);
    // enter some text for the TextField "Test"
    await tester.enterText(foundTextField, 'Test');
    expect(
        (foundTextField.evaluate().first.widget as TextField).controller?.text,
        'Test');

    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    // expect that we have a Scrollbar
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(tester.getSize(find.byType(Scrollbar)), Size(800.0, 55.0 * 3.0));
    // make sure we have 8 found
    expect(find.byType(ListTile, skipOffstage: false), findsNWidgets(8));
  });

  testWidgets(
      'TextFieldSearch can have itemsInView customization for scrollbar',
      (WidgetTester tester) async {
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();

    // mocking a future that takes 1000ms to resolve
    Future<List> fetchData() async {
      await Future.delayed(Duration(milliseconds: 2000));
      List _list = <dynamic>[];
      String _inputText = myController.text;
      // create a list from the text input of three items
      // to mock a list of items from an http call
      for (var i = 0; i <= 10; i++) {
        _list.add(_inputText + ' Item ' + i.toString());
      }

      return _list;
    }

    // Build an app with the TextFieldSearch
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: TextFieldSearch(
        key: testKey,
        label: label,
        scrollbarDecoration: ScrollbarDecoration(
            controller: ScrollController(),
            theme: ScrollbarThemeData(
                isAlwaysShown: true,
                thickness: MaterialStateProperty.all(10.0))),
        itemsInView: 5,
        controller: myController,
        future: () {
          return fetchData();
        },
      )),
    ));

    // find the TextField by it's type
    var foundTextField = find.byType(TextField);
    // enter some text for the TextField "Test"
    await tester.enterText(foundTextField, 'Test');
    expect(
        (foundTextField.evaluate().first.widget as TextField).controller?.text,
        'Test');

    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    // expect that we have a Scrollbar
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(tester.getSize(find.byType(Scrollbar)), Size(800.0, 55.0 * 5.0));
    // make sure we have 10 found
    expect(find.byType(ListTile, skipOffstage: false), findsNWidgets(10));
  });

  testWidgets(
      'TextFieldSearch scrollbar will have height of 55 when one item is found',
      (WidgetTester tester) async {
    const String label = 'Test Label';
    const Key testKey = Key('K');
    final TextEditingController myController = TextEditingController();

    // mocking a future that takes 1000ms to resolve
    Future<List> fetchData() async {
      await Future.delayed(Duration(milliseconds: 2000));
      List _list = <dynamic>[];
      String _inputText = myController.text;
      // create a list from the text input of three items
      // to mock a list of items from an http call
      _list.add(_inputText + ' Item 1');

      return _list;
    }

    // Build an app with the TextFieldSearch
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: TextFieldSearch(
        key: testKey,
        label: label,
        scrollbarDecoration: ScrollbarDecoration(
            controller: ScrollController(),
            theme: ScrollbarThemeData(
                isAlwaysShown: true,
                thickness: MaterialStateProperty.all(10.0))),
        controller: myController,
        future: () {
          return fetchData();
        },
      )),
    ));

    // find the TextField by it's type
    var foundTextField = find.byType(TextField);
    // enter some text for the TextField "Test"
    await tester.enterText(foundTextField, 'Test');
    expect(
        (foundTextField.evaluate().first.widget as TextField).controller?.text,
        'Test');

    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    // expect that we have a Scrollbar
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(tester.getSize(find.byType(Scrollbar)), Size(800.0, 55.0 * 1.0));
    // make sure we have 10 found
    expect(find.byType(ListTile), findsNWidgets(1));
  });

  testWidgets(
      'TextFieldSearch scrollbar will have height of 55 when one item is found',
      (WidgetTester tester) async {
    const String label = 'Test Label';
    const Key testKey = Key('K');
    const String hintText = 'Search For Something';
    final TextEditingController myController = TextEditingController();

    // mocking a future that takes 1000ms to resolve
    Future<List> fetchData() async {
      await Future.delayed(Duration(milliseconds: 2000));
      List _list = <dynamic>[];
      String _inputText = myController.text;
      // create a list from the text input of three items
      // to mock a list of items from an http call
      _list.add(_inputText + ' Item 1');

      return _list;
    }

    // Build an app with the TextFieldSearch
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: TextFieldSearch(
        key: testKey,
        label: label,
        scrollbarDecoration: ScrollbarDecoration(
            controller: ScrollController(),
            theme: ScrollbarThemeData(
                isAlwaysShown: true,
                thickness: MaterialStateProperty.all(10.0))),
        decoration: InputDecoration(hintText: hintText),
        controller: myController,
        future: () {
          return fetchData();
        },
      )),
    ));

    // find the TextField by it's type
    var foundTextField = find.byType(TextField);
    // enter some text for the TextField "Test"
    await tester.enterText(foundTextField, 'Test');
    expect(
        (foundTextField.evaluate().first.widget as TextField).controller?.text,
        'Test');

    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    expect(
        (foundTextField.evaluate().first.widget as TextField)
            .decoration
            ?.hintText,
        hintText);
  });

  test('Debouncer executes function only once despite repeated calls',
      () async {
    // test that debouncer waits for 1000ms before calling function
    Debouncer _debouncer = Debouncer(milliseconds: 1000);
    // expect that the value we pass for milliseconds is the same
    expect(_debouncer.milliseconds, 1000);
    // empty list to add an Item to
    List _testList = <dynamic>[];
    // function to attempt to call multiple times that adds an item to a list
    void testFn() {
      _testList.add('Item');
    }

    // call the function immediately
    _debouncer.run(() => testFn());
    // since debounce is after 1000ms, the testList should still be empty
    expect(_testList.length, 0);

    // Call the function several times with 500ms between each call
    for (var i = 0; i < 10; i++) {
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
  TestItem({required this.label, this.value});

  factory TestItem.fromJson(Map<String, dynamic> json) {
    return TestItem(label: json['label'], value: json['value']);
  }
}
