// EXAMPLE use case for TextFieldSearch Widget
import 'package:flutter/material.dart';

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

class TextFieldSearch extends StatefulWidget {
  final List initialList;
  final String label;

  const TextFieldSearch({
    Key key,
    @required this.initialList,
    @required this.label
  }) : super(key: key);

  @override
  _TextFieldSearchState createState() => _TextFieldSearchState();
}

class _TextFieldSearchState extends State<TextFieldSearch> {
  final FocusNode _focusNode = FocusNode();
  OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List filteredList = new List();
  final myController = TextEditingController();


  void resetList() {
    List tempList = new List();
    setState(() {
      // after loop is done, set the filteredList state from the tempList
      this.filteredList = tempList;
    });
    // mark that the overlay widget needs to be rebuilt
    this._overlayEntry.markNeedsBuild();
  }

  void updateList() {
    this.filteredList = widget.initialList;
    List tempList = new List();
    // loop through each item in filtered items
    for (int i = 0; i < filteredList.length; i++) {
      // lowercase the item and see if the item contains the string of text from the lowercase search
      if (this.filteredList[i].toLowerCase().contains(myController.text.toLowerCase())) {
        // if there is a match, add to the temp list
        tempList.add(this.filteredList[i]);
      }
    }
    // if no items are found, add message none found
    if (tempList.length == 0 && myController.text.isNotEmpty) {
      tempList.add('No matching styles');
    }
    if (myController.text.isEmpty){
      tempList = List();
    }
    setState(() {
      // after loop is done, set the filteredList state from the tempList
      this.filteredList = tempList;
    });
    // mark that the overlay widget needs to be rebuilt
    this._overlayEntry.markNeedsBuild();
  }

  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus){
        this._overlayEntry = this._createOverlayEntry();
        Overlay.of(context).insert(this._overlayEntry);
      } else {
        this._overlayEntry.remove();
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  OverlayEntry _createOverlayEntry() {

    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;

    return OverlayEntry(
        builder: (context) => Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, size.height + 5.0),
            child: Material(
              elevation: 4.0,
              child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, i){
                  return GestureDetector(
                    onTap: (){
                      // set the controller value to what was selected
                      setState(() {
                        myController.text = filteredList[i];
                      });
                      // reset the list so it's empty and not visible
                      resetList();
                      // remove the focus node so we aren't editing the text
                      FocusScope.of(context).unfocus();
                    },
                    child: ListTile(
                        title: Text(filteredList[i])
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                shrinkWrap: true,
              ),
            ),
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: this._layerLink,
      child: TextField(
        controller: myController,
        focusNode: this._focusNode,
        decoration: InputDecoration(
            labelText: widget.label
        ),
        onChanged: (String value) {
          updateList();
        },
      ),
    );
  }
}
