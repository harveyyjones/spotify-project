import 'package:flutter/material.dart';

class SizedIconButton extends StatefulWidget {
  SizedIconButton({this.width, this.icon, this.onPressed});
  var width;
  var icon;
  var onPressed;

  @override
  State<SizedIconButton> createState() => _SizedIconButtonState();
}

class _SizedIconButtonState extends State<SizedIconButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          setState(() {
            widget.onPressed;
          });
        },
        icon: Icon(
          widget.icon,
          size: 50,
        ));
  }
}
