import 'package:flutter/material.dart';

class TextFieldSearch extends StatefulWidget {
  final List initialList;
  final String label;
  final TextEditingController controller;
  const TextFieldSearch({
    Key key,
    @required this.initialList,
    @required this.label,
    @required this.controller,xs
  }) : super(key: key);

  @override
  _TextFieldSearchState createState() => _TextFieldSearchState();
}

class _TextFieldSearchState extends State<TextFieldSearch> {
  final FocusNode _focusNode = FocusNode();
  OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List filteredList = new List();

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
      if (this.filteredList[i].toLowerCase().contains(widget.controller.text.toLowerCase())) {
        // if there is a match, add to the temp list
        tempList.add(this.filteredList[i]);
      }
    }
    // if no items are found, add message none found
    if (tempList.length == 0 && widget.controller.text.isNotEmpty) {
      tempList.add('No matching styles');
    }
    if (widget.controller.text.isEmpty){
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
    // adding error handling for required params
    if (widget.controller == null) {
      throw('Error: Missing required parameter: controller');
    }
    if (widget.label == null) {
      throw('Error: Missing required parameter: label');
    }
    if (widget.initialList == null || widget.initialList.length == 0) {
      throw('Error: Missing required initial list or initial list is empty array');
    }
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
    widget.controller.dispose();
    super.dispose();
  }

  OverlayEntry _createOverlayEntry() {

    RenderBox renderBox = context.findRenderObject();
    Size overlaySize = renderBox.size;
    Offset position = renderBox.localToGlobal(Offset.zero); // get global position of renderBox
    double y = position.dy; // get y coordinate
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    const BOTTOM_OFFSET = 75;
    return OverlayEntry(
        builder: (context) => Positioned(
          width: overlaySize.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, overlaySize.height + 5.0),
            child: Material(
              elevation: 4.0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: screenWidth,
                    maxWidth: screenWidth,
                    minHeight: 0,
                    // make sure we have a max dynamic height of 400
                    maxHeight: (screenHeight - y) - BOTTOM_OFFSET > 400 ? 400 : (screenHeight - y) - BOTTOM_OFFSET,
                ),
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, i){
                    return GestureDetector(
                      onTap: (){
                        // set the controller value to what was selected
                        setState(() {
                          widget.controller.text = filteredList[i];
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
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: this._layerLink,
      child: TextField(
        controller: widget.controller,
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