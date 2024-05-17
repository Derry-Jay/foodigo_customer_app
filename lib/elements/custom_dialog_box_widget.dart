import 'package:flutter/material.dart';

class CustomDialogBoxWidget extends StatelessWidget {
  final Widget child;

  CustomDialogBoxWidget({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AnimatedContainer(
        duration: const Duration(milliseconds: 300), child: child);
  }
}
