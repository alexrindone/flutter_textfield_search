// EXAMPLE use case for TextFieldSearch Widget
import 'package:flutter/material.dart';
import 'package:textfield_search/textfield_search.dart';

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
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Brewery'
                ),
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
              TextFieldSearch(initialList: listOfStyles, label: 'Style',),
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
