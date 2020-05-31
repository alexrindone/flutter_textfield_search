// EXAMPLE use case for TextFieldSearch Widget
import 'package:flutter/material.dart';
import 'package:textfield_search/textfield_search.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final listOfStyles = [
    'Stout',
    'Oatmeal Stout',
    'Chocolate Stout',
    'Gose',
    'IPA',
    'New England IPA',
    'India Pale Ale',
    'Lager',
    'Ale',
    'Red Ale'
  ];

  TextEditingController myController = TextEditingController();
  TextEditingController myController2 = TextEditingController();


  @override
  void initState() {
    super.initState();
    myController.addListener(_printLatestValue);
    myController2.addListener(_printLatestValue);

  }

  _printLatestValue() {
    print("text field: ${myController.text}");
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    myController.dispose();
    myController2.dispose();
    super.dispose();
  }

  // mocking a future
  Future<List> fetchData() async {
    await Future.delayed(Duration(milliseconds: 5000));
    List _list = new List();
    String _inputText = myController2.text;
    // create a list from the text input of three items
    // to mock a list of items from an http call
    _list.add(_inputText + ' Item 1');
    _list.add(_inputText + ' Item 2');
    _list.add(_inputText + ' Item 3');
    return _list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Form(
          child: ListView(
            children: <Widget>[
              SizedBox(height: 16),
              TextFieldSearch(
                  initialList: listOfStyles,
                  label: 'Brewery',
                  controller: myController2,
                  future: () {
                    return fetchData();
                  }
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Beer Name'
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Description'
                ),
              ),
              TextFieldSearch(
                initialList: listOfStyles,
                label: 'Style',
                controller: myController
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'ABV.'
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'IBU'
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}