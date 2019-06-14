import 'package:flutter/material.dart';

class SegmentControl extends StatefulWidget {
  const SegmentControl({
    Key key,
    this.titles,
    this.selectedIndex,
    @required this.onPressed,
  }) : super(key: key);

  final List<String> titles;

  final int selectedIndex;

  final void Function(int) onPressed;

  @override
  _SegmentControlState createState() => _SegmentControlState(selectedIndex);
}

class _SegmentControlState extends State<SegmentControl> {
  int _selectedIndex = 0;

  _SegmentControlState(this._selectedIndex);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: new EdgeInsets.all(4),
      child: Row(
        children: _createChildren(),
      ),
    );
  }

  List<Widget> _createChildren() {
    return List<Widget>.generate(widget.titles.length, (int index) {
      String title = widget.titles[index];
      MaterialColor color;
      if (index == _selectedIndex) {
        color = Colors.red;
      } else {
        color = Colors.blue;
      }
      return Expanded(
        child: FlatButton(
          onPressed: () => selectButton(index),
          child: Text(title),
          textColor: color,
        ),
      );
    });
  }

  void selectButton(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (widget.onPressed != null) {
      widget.onPressed(index);
    }
  }
}
