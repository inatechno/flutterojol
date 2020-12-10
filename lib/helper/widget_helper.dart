import 'package:flutter/material.dart';

class WidgetHelper {
  Widget myTextFormField(
      TextEditingController controller,
      String label,
      bool isPassword,
      TextInputType textInput,
      String hint,
      IconData iconPrefix,
      String Function(String) validator,
      FocusNode fromNode,
      FocusNode toNode,
      bool autofocus,
      BuildContext context) {
    return TextFormField(
      obscureText: isPassword,
      autofocus: autofocus,
      validator: validator,
      controller: controller,
      keyboardType: textInput,
      focusNode: fromNode,
      onFieldSubmitted: (value) => FocusScope.of(context).requestFocus(toNode),
      decoration: InputDecoration(
        // labelText: label,
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        errorMaxLines: 1,

        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        hintText: hint,
        focusColor: Colors.orange,
        fillColor: Colors.white24,
        prefixIcon: Icon(
          iconPrefix,
        ),
      ),
    );
  }
}
