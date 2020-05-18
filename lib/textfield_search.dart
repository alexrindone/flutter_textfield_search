import 'package:flutter/material.dart';

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
  final textFieldController = TextEditingController();

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
    // set the filtered list using the initial list
    this.filteredList = widget.initialList;
    // create an empty temp list
    List tempList = new List();
    // loop through each item in filtered items
    for (int i = 0; i < filteredList.length; i++) {
      // lowercase the item and see if the item contains the string of text from the lowercase search
      if (this.filteredList[i].toLowerCase().contains(textFieldController.text.toLowerCase())) {
        // if there is a match, add to the temp list
        tempList.add(this.filteredList[i]);
      }
    }
    // if no items are found, add message none found
    if (tempList.length == 0 && textFieldController.text.isNotEmpty) {
      tempList.add('No matching styles');
    }
    if (textFieldController.text.isEmpty){
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
    // add event listener to the focus node and only give an overlay if an entry
    // has focus and insert the overlay into Overlay context otherwise remove it
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
    textFieldController.dispose();
    super.dispose();
  }

  OverlayEntry _createOverlayEntry() {

    RenderBox renderBox = context.findRenderObject();
    Size overlaySize = renderBox.size;

    return OverlayEntry(
        builder: (context) => Positioned(
          width: overlaySize.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, overlaySize.height + 5.0),
            child: Material(
              elevation: 4.0,
              child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, i){
                  return GestureDetector(
                    onTap: (){
                      // set the controller value to what was selected
                      setState(() {
                        textFieldController.text = filteredList[i];
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
        controller: textFieldController,
        focusNode: this._focusNode,
        decoration: InputDecoration(
            labelText: widget.label
        ),
        onChanged: (String value) {
          // every time we make a change to the input, update the list
          // FUTURE: add debouncing to help with performance
          updateList();
        },
      ),
    );
  }
}