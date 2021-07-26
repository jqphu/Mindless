import 'package:flutter/material.dart';

import 'colors.dart';

TextFormField buildFormField(
    BuildContext context,
    String label,
    String validateText,
    TextEditingController controller,
    FocusNode focusNode) {
  return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: focusNode.hasFocus
                ? Theme.of(context).accentColor
                : kUnfocusedColor),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return validateText;
        }
        return null;
      });
}
