# flutter_textfield_search

A new Flutter package which uses a TextField to search and select it's value from a simple list.

## Usage
To use this package, add flutter_textfield_search as a dependency in your pubsec.yaml file.

## Example
Import the package.

    `import 'package:flutter_textfield_search/search.dart'`;

Then include the widget anywhere you would normally use a TextField widget with a label, and a List
    <br>Example MaterialApp using TextFieldSearch Widget
    <br>

        const label = "Some Label";
        const dummyList = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'];
        MaterialApp(
          home: Scaffold(
            body: TextFieldSearch(initialList: dummyList, label: label)
          ),
        )

## Issues

Please email any issues, bugs, or additional features you would like to see built to arindone@nubeer.io.

## Contributing

If you wish to contribute to this package you may fork the repository and make a pull request to this repository.
