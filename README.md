# flutter_textfield_search
![Build and Test](https://github.com/alexrindone/flutter_textfield_search/workflows/Build%20and%20Tests/badge.svg)

FTFS is a Flutter package which uses a TextField Widget to search and select a value from a list. It's a simple, lightweight, and fully tested package unlike other "autocomplete" or textfield search packages. View complete code coverage results in JSON format  **[here](https://raw.githubusercontent.com/alexrindone/flutter_textfield_search/master/coverage/coverage.json)**.

## Usage
To use this package, add flutter_textfield_search as a dependency in your pubsec.yaml file.

## Example
Import the package.

    `import 'package:flutter_textfield_search/search.dart'`;

Then include the widget anywhere you would normally use a TextField widget with a String for label, a List for initialList, and a TextEditingController for controller.
    <br>Example MaterialApp using TextFieldSearch Widget
    <br>

        const label = "Some Label";
        const dummyList = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'];
        TextEditingController myController = TextEditingController();
        MaterialApp(
          home: Scaffold(
          body: TextFieldSearch(initialList: dummyList, label: label, controller: myController)
          ),
        )
        
To get the value of the selected option, use addListener on the controller to listen for changes:

        @override
        void dispose() {
          // Clean up the controller when the widget is removed from the
          // widget tree.
          myController.dispose();
          super.dispose();
        }

        @override
        void initState() {
          super.initState();
          // Start listening to changes.
          myController.addListener(_printLatestValue);
        }
        
        _printLatestValue() {
          print("Textfield value: ${myController.text}");
        }

## Issues

Please email any issues, bugs, or additional features you would like to see built to arindone@nubeer.io.

## Contributing

If you wish to contribute to this package you may fork the repository and make a pull request to this repository.
<br><br>**Note**: Testing by running `flutter test --coverage` will generate `coverage/lcov.info`. Running `bash test-coverage.sh` will parse the `lcov.info` file into JSON format. This happens automatically within the CI/CD pipeline on a pull request to master but it is always good to test locally.
