import 'package:flutter/material.dart';
// stuff for debouncing
import 'package:flutter/foundation.dart';
import 'dart:async';

class TextFieldSearch extends StatefulWidget {
  final List initialList;
  final String label;
  final TextEditingController controller;
  final Function future;
  final Function getSelectedValue;
  const TextFieldSearch({
    Key key,
    this.initialList,
    @required this.label,
    @required this.controller,
    this.future,
    this.getSelectedValue
  }) : super(key: key);

  @override
  _TextFieldSearchState createState() => _TextFieldSearchState();
}

class _TextFieldSearchState extends State<TextFieldSearch> {
  final FocusNode _focusNode = FocusNode();
  OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List filteredList = new List();
  bool hasFuture = false;
  bool loading = false;
  final _debouncer = Debouncer(milliseconds: 1000);

  void resetList() {
    List tempList = new List();
    setState(() {
      // after loop is done, set the filteredList state from the tempList
      this.filteredList = tempList;
    });
    // mark that the overlay widget needs to be rebuilt
    this._overlayEntry.markNeedsBuild();
  }

  void updateGetItems(){
    // mark that the overlay widget needs to be rebuilt
    // so loader can show
    this._overlayEntry.markNeedsBuild();
    if (widget.controller.text.length > 2) {
      setState(() {
        loading = true;
      });
      widget.future().then((value) {
        this.filteredList = value;
        // create an empty temp list
        List tempList = new List();
        // loop through each item in filtered items
        for (int i = 0; i < filteredList.length; i++) {
          // lowercase the item and see if the item contains the string of text from the lowercase search
            if (widget.getSelectedValue != null) {
              if (this.filteredList[i].label.toLowerCase().contains(widget.controller.text.toLowerCase())) {
                // if there is a match, add to the temp list
                tempList.add(this.filteredList[i]);
              }
            } else {
              if (this.filteredList[i].toLowerCase().contains(widget.controller.text.toLowerCase())) {
                // if there is a match, add to the temp list
                tempList.add(this.filteredList[i]);
              }
            }
        }
        // if no items are found, add message none found
        if (tempList.length == 0 && widget.controller.text.isNotEmpty) {
          tempList.add('No matching items');
        }
        setState(() {
          // after loop is done, set the filteredList state from the tempList
          this.filteredList = tempList;
          this.loading = false;
        });
        // mark that the overlay widget needs to be rebuilt so results can show
        this._overlayEntry.markNeedsBuild();
      });
    } else {
      // reset the list if we ever have less than 2 characters
      resetList();
    }
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
      tempList.add('No matching items');
    }
    if (widget.controller.text.isEmpty || widget.controller.text == ''){
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
    // throw error if we don't have an inital list or a future
    if (widget.initialList == null && widget.future == null) {
      throw('Error: Missing required initial list or future that returns list');
    }
    if (widget.future != null) {
      setState(() {
        hasFuture = true;
      });
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
  
  ListView _listViewBuilder(context) {
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, i){
        return GestureDetector(
          onTap: (){
            // set the controller value to what was selected
            setState(() {
              // if we have a label property, and getSelectedValue function
              // send getSelectedValue to parent widget using the label property
              if (widget.getSelectedValue != null) {
                widget.controller.text = filteredList[i].label;
                widget.getSelectedValue(filteredList[i]);
              } else {
                widget.controller.text = filteredList[i];
              }
            });
            // reset the list so it's empty and not visible
            resetList();
            // remove the focus node so we aren't editing the text
            FocusScope.of(context).unfocus();
          },
          child: ListTile(
              title: widget.getSelectedValue != null ? Text(filteredList[i].label) : Text(filteredList[i])
          ),
        );
      },
      padding: EdgeInsets.zero,
      shrinkWrap: true,
    );
  }

  Widget _loadingIndicator() {
    return Container(
      width: 50,
      height: 50,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
        ),
      ),
    );
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
                child: loading ? _loadingIndicator() : _listViewBuilder(context)
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
            _debouncer.run(() {
              setState(() {
                if (hasFuture) {
                  updateGetItems();
                } else {
                  updateList();
                }
              });
            });
        },
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;
  Debouncer({ this.milliseconds });
  run(VoidCallback action) {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}