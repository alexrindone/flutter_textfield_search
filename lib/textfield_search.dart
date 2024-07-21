import 'package:flutter/material.dart';
import 'dart:async';

class TextFieldSearch extends StatefulWidget {
  /// A default list of values that can be used for an initial list of elements to select from
  final List? initialList;

  /// A string used for display of the selectable elements
  final String label;

  /// A controller for an editable text field
  final TextEditingController controller;

  /// An optional future or async function that should return a list of selectable elements
  final Function? future;

  /// The value selected on tap of an element within the list
  final Function? getSelectedValue;
  
  
  /// Used for customizing the display of the CursorColor
  final MaterialColor? cursorColor;

  /// Used for customizing the display of the TextField
  final InputDecoration? decoration;

  /// Used for customizing the style of the text within the TextField
  final TextStyle? textStyle;

  /// Used for customizing the scrollbar for the scrollable results
  final ScrollbarDecoration? scrollbarDecoration;

  /// The minimum length of characters to be entered into the TextField before executing a search
  final int minStringLength;

  /// The number of matched items that are viewable in results
  final int itemsInView;
  
  // Initial value for textformField
  final String? initialValue;

  /// A boolean used for deciding whether or not to clear TextField when unfocused
  final bool autoClear;

  /// Creates a TextFieldSearch for displaying selected elements and retrieving a selected element
  const TextFieldSearch(
      {Key? key,
      this.initialList,
      required this.label,
      required this.controller,
      this.textStyle,
      this.future,
      this.initialValue = "",
      this.getSelectedValue,
      this.cursorColor,
      this.decoration,
      this.scrollbarDecoration,
      this.itemsInView = 3,
      this.minStringLength = 2,
      this.autoClear = true})
      : super(key: key);

  @override
  _TextFieldSearchState createState() => _TextFieldSearchState();
}

class _TextFieldSearchState extends State<TextFieldSearch> {
  final FocusNode _focusNode = FocusNode();
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List? filteredList = <dynamic>[];
  bool hasFuture = false;
  bool loading = false;
  final _debouncer = Debouncer(milliseconds: 1000);
  static const itemHeight = 55;
  bool? itemsFound;
  ScrollController _scrollController = ScrollController();

  void resetList() {
    List tempList = <dynamic>[];
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
    if (widget.controller.text.length > widget.minStringLength) {
      this.setLoading();
      widget.future!().then((value) {
        this.filteredList = value;
        // create an empty temp list
        List tempList = <dynamic>[];
        // loop through each item in filtered items
        for (int i = 0; i < filteredList!.length; i++) {
          // lowercase the item and see if the item contains the string of text from the lowercase search
          if (widget.getSelectedValue != null) {
            if (this
                .filteredList![i]
                .label
                .toLowerCase()
                .contains(widget.controller.text.toLowerCase())) {
              // if there is a match, add to the temp list
              tempList.add(this.filteredList![i]);
            }
          } else {
            if (this
                .filteredList![i]
                .toLowerCase()
                .contains(widget.controller.text.toLowerCase())) {
              // if there is a match, add to the temp list
              tempList.add(this.filteredList![i]);
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
    this.setLoading();
    // set the filtered list using the initial list
    this.filteredList = widget.initialList;

    // create an empty temp list
    List tempList = <dynamic>[];
    // loop through each item in filtered items
    for (int i = 0; i < filteredList!.length; i++) {
      // lowercase the item and see if the item contains the string of text from the lowercase search
      if (this
          .filteredList![i]
          .toLowerCase()
          .contains(widget.controller.text.toLowerCase())) {
        // if there is a match, add to the temp list
        tempList.add(this.filteredList![i]);
      }
    }
    // helper function to set tempList and other state props
    this.resetState(tempList);
  }

  void initState() {
    super.initState();

    if (widget.scrollbarDecoration?.controller != null) {
      _scrollController = widget.scrollbarDecoration!.controller;
    }

    // throw error if we don't have an initial list or a future
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
        Overlay.of(context)!.insert(this._overlayEntry);
      } else {
        this._overlayEntry.remove();
        // check to see if itemsFound is false, if it is clear the input
        // check to see if we are currently loading items when keyboard exists, and clear the input
        if (itemsFound == false || loading == true) {
          // reset the list so it's empty and not visible
          resetList();
          if (widget.autoClear == true) widget.controller.clear();
          
        }
        // if we have a list of items, make sure the text input matches one of them
        // if not, clear the input
        if (filteredList!.length > 0) {
          bool textMatchesItem = false;
          if (widget.getSelectedValue != null) {
            // try to match the label against what is set on controller
            textMatchesItem = filteredList!
                .any((item) => item.label == widget.controller.text);
          } else {
            textMatchesItem = filteredList!.contains(widget.controller.text);
          }
          if (textMatchesItem == false && widget.autoClear == true) widget.controller.clear();
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
        controller: _scrollController,
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
      controller: _scrollController,
      itemCount: filteredList!.length,
      itemBuilder: (context, i) {
        return GestureDetector(
            onTap: () {
              // set the controller value to what was selected
              setState(() {
                // if we have a label property, and getSelectedValue function
                // send getSelectedValue to parent widget using the label property
                if (widget.getSelectedValue != null) {
                  widget.controller.text = filteredList![i].label;
                  widget.getSelectedValue!(filteredList![i]);
                } else {
                  widget.controller.text = filteredList![i];
                }
              });
              // reset the list so it's empty and not visible
              resetList();
              // remove the focus node so we aren't editing the text
              FocusScope.of(context).unfocus();
            },
            child: ListTile(
                title: widget.getSelectedValue != null
                    ? Text(filteredList![i].label)
                    : Text(filteredList![i])));
      },
      padding: EdgeInsets.zero,
      shrinkWrap: true,
    );
  }

  /// A default loading indicator to display when executing a Future
  Widget _loadingIndicator() {
    return Container(
      width: 50,
      height: 50,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }

  Widget decoratedScrollbar(child) {
    if (widget.scrollbarDecoration is ScrollbarDecoration) {
      return Theme(
        data: Theme.of(context)
            .copyWith(scrollbarTheme: widget.scrollbarDecoration!.theme),
        child: Scrollbar(child: child, controller: _scrollController),
      );
    }

    return Scrollbar(child: child);
  }

  Widget? _listViewContainer(context) {
    if (itemsFound == true && filteredList!.length > 0 ||
        itemsFound == false && widget.controller.text.length > 0) {
      return Container(
          height: calculateHeight().toDouble(),
          child: decoratedScrollbar(_listViewBuilder(context)));
    }
    return null;
  }

  num heightByLength(int length) {
    return itemHeight * length;
  }

  num calculateHeight() {
    if (filteredList!.length > 1) {
      if (widget.itemsInView <= filteredList!.length) {
        return heightByLength(widget.itemsInView);
      }

      return heightByLength(filteredList!.length);
    }

    return itemHeight;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
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
                        maxHeight: calculateHeight().toDouble(),
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
        initialValue : widget.initialValue,
        controller: widget.controller,
        cursorColor: widget.cursorColor != null
            ? widget.cursorColor
            : Colors.white,
        focusNode: this._focusNode,
        decoration: widget.decoration != null
            ? widget.decoration
            : InputDecoration(labelText: widget.label),
        style: widget.textStyle,
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
  /// A length of time in milliseconds used to delay a function call
  final int? milliseconds;

  /// A callback function to execute
  VoidCallback? action;

  /// A count-down timer that can be configured to fire once or repeatedly.
  Timer? _timer;

  /// Creates a Debouncer that executes a function after a certain length of time in milliseconds
  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds!), action);
  }
}

class ScrollbarDecoration {
  const ScrollbarDecoration({
    required this.controller,
    required this.theme,
  });

  /// {@macro flutter.widgets.Scrollbar.controller}
  final ScrollController controller;

  /// {@macro flutter.widgets.ScrollbarThemeData}
  final ScrollbarThemeData theme;
}
