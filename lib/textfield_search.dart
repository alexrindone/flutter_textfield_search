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
  final int amountOfCharacters;

  const TextFieldSearch(
      {Key key,
      this.initialList,
      @required this.label,
      @required this.controller,
      this.future,
      this.getSelectedValue,
      this.amountOfCharacters = 3})
      : super(key: key);

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
  bool itemsFound;

  void resetList() {
    List tempList = new List();
    setState(() {
      // after loop is done, set the filteredList state from the tempList
      this.filteredList = tempList;
      this.loading = false;
    });
    // mark that the overlay widget needs to be rebuilt
    this._overlayEntry.markNeedsBuild();
  }

  void setLoading() {
    if (!this.loading) {
      setState(() {
        this.loading = true;
      });
    }
  }

  void resetState(List tempList) {
    setState(() {
      // after loop is done, set the filteredList state from the tempList
      this.filteredList = tempList;
      this.loading = false;
      // if no items are found, add message none found
      itemsFound = tempList.length == 0 && widget.controller.text.isNotEmpty
          ? false
          : true;
    });
    // mark that the overlay widget needs to be rebuilt so results can show
    this._overlayEntry.markNeedsBuild();
  }

  void updateGetItems() {
    // mark that the overlay widget needs to be rebuilt
    // so loader can show
    this._overlayEntry.markNeedsBuild();
    if (widget.controller.text.length > widget.amountOfCharacters) {
      this.setLoading();
      widget.future().then((value) {
        this.filteredList = value;
        // create an empty temp list
        List tempList = new List();
        // loop through each item in filtered items
        for (int i = 0; i < filteredList.length; i++) {
          // lowercase the item and see if the item contains the string of text from the lowercase search
          if (widget.getSelectedValue != null) {
            if (this
                .filteredList[i]
                .label
                .toLowerCase()
                .contains(widget.controller.text.toLowerCase())) {
              // if there is a match, add to the temp list
              tempList.add(this.filteredList[i]);
            }
          } else {
            if (this
                .filteredList[i]
                .toLowerCase()
                .contains(widget.controller.text.toLowerCase())) {
              // if there is a match, add to the temp list
              tempList.add(this.filteredList[i]);
            }
          }
        }
        // helper function to set tempList and other state props
        this.resetState(tempList);
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
      if (this
          .filteredList[i]
          .toLowerCase()
          .contains(widget.controller.text.toLowerCase())) {
        // if there is a match, add to the temp list
        tempList.add(this.filteredList[i]);
      }
    }
    // helper function to set tempList and other state props
    this.resetState(tempList);
  }

  void initState() {
    super.initState();
    // adding error handling for required params
    if (widget.controller == null) {
      throw ('Error: Missing required parameter: controller');
    }
    if (widget.label == null) {
      throw ('Error: Missing required parameter: label');
    }
    // throw error if we don't have an inital list or a future
    if (widget.initialList == null && widget.future == null) {
      throw ('Error: Missing required initial list or future that returns list');
    }
    if (widget.future != null) {
      setState(() {
        hasFuture = true;
      });
    }
    // add event listener to the focus node and only give an overlay if an entry
    // has focus and insert the overlay into Overlay context otherwise remove it
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        this._overlayEntry = this._createOverlayEntry();
        Overlay.of(context).insert(this._overlayEntry);
      } else {
        this._overlayEntry.remove();
        // check to see if itemsFound is false, if it is clear the input
        // check to see if we are currently loading items when keyboard exists, and clear the input
        if (itemsFound == false || loading == true) {
          // reset the list so it's empty and not visible
          resetList();
          widget.controller.clear();
        }
        // if we have a list of items, make sure the text input matches one of them
        // if not, clear the input
        if (filteredList.length > 0) {
          bool textMatchesItem = false;
          if (widget.getSelectedValue != null) {
            // try to match the label against what is set on controller
            textMatchesItem = filteredList
                .any((item) => item.label == widget.controller.text);
          } else {
            textMatchesItem = filteredList.contains(widget.controller.text);
          }
          if (textMatchesItem == false) widget.controller.clear();
          resetList();
        }
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
    if (itemsFound == false) {
      return ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              // clear the text field controller to reset it
              widget.controller.clear();
              setState(() {
                itemsFound = false;
              });
              // reset the list so it's empty and not visible
              resetList();
              // remove the focus node so we aren't editing the text
              FocusScope.of(context).unfocus();
            },
            child: ListTile(
              title: Text('No matching items.'),
              trailing: Icon(Icons.cancel),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, i) {
        return GestureDetector(
            onTap: () {
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
                title: widget.getSelectedValue != null
                    ? Text(filteredList[i].label)
                    : Text(filteredList[i])));
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
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
        ),
      ),
    );
  }

  Widget _listViewContainer(context) {
    if (itemsFound == true && filteredList.length > 0 ||
        itemsFound == false && widget.controller.text.length > 0) {
      double _height = itemsFound == true && filteredList.length > 1 ? 110 : 55;
      return Container(
        height: _height,
        child: _listViewBuilder(context),
      );
    }
    return null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    Size overlaySize = renderBox.size;
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
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
                        // max height set to 150
                        maxHeight: itemsFound == true ? 110 : 55,
                      ),
                      child: loading
                          ? _loadingIndicator()
                          : _listViewContainer(context)),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: this._layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: this._focusNode,
        decoration: InputDecoration(labelText: widget.label),
        onChanged: (String value) {
          // every time we make a change to the input, update the list
          this.setLoading();
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

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
