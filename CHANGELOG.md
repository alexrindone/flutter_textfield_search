# Changelog
## 0.10.0
4-19-2022
- Adding support for styling scrollbar with longer lists
- Adding support to change height of the scroll widget
- Adding better tests and coverage for decoration of text input
- special thanks to @maykhid for input and ideas on scrollbar decoration

## 0.9.2
1-22-2022
- Fixing formatting

## 0.9.1
1-22-2022
- Added documentation leveraging dartdoc

## 0.9.0
1-22-2022
- Added null safety

## 0.8.0
3-3-2021
- Added minStringLength which allows for setting a minimum query string length before executing search
- Added support for InputDecoration through decoration
- Added support for TextStyle through textStyle

## 0.7.0
10-13-2020
- Fixing issue Class 'String' has no instance getter 'label' when 'No matching items.' is shown
- Fixing test cases to check for when 'No matching items.' is found
- Added functionality to clear the input if a user submits a TextField that doesn't match an item in the list
- Added functionality to clear the input if a user submits a TextField as the list is currently loading

## 0.6.1
6-5-2020
- Updating README.md to include functionality giphy
- Adding loading spinner on value change to show results are being loaded when user interacts with input

## 0.6.0
6-3-2020
- Added the ability to show a list of objects that have a required property of label (to display within the TextField)
- Added getSelectedValue() callback function which returns the selected value which could be used to get an object instead of the TextField's value

## 0.5.0
5-31-2020
- Added future parameter that allows for a Future that returns a list to be used
- With the addition of the Future, users can now select an option from a list provided by a Future

## 0.4.0
5-27-2020
- Added required param textFieldController so addEventListener can be used on passed in controller
- Added ContrainedBox with a maximum height so the widget is scrollable and doesn't overflow outside the bounds of the screen

## 0.3.0
5-23-2020
- Added automated testing to CI/CD pipelines
- Added code coverage to CI/CD pipelines via bash script that's auto commited to repo

## 0.2.0
Initial Release
- Delivering an easy to use text field that searches through a predefined list of selectable options
- Developers can set the label for the text field and the static list of options to be searched and selected from
