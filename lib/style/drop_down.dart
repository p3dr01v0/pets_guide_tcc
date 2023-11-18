import 'package:flutter/material.dart';

class dropStyle {
  static InputDecoration dropdownDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: InputBorder.none, // Removendo a linha do texto
    );
  }

  static BoxDecoration dropdownContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25.0),
      border: Border.all(
        color: Colors.black,
        width: 1,
      ),
    );
  }

  static EdgeInsets dropdownPadding = const EdgeInsets.symmetric(horizontal: 12.0);

  static Widget sizedDropdownContainer(Widget dropdown) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 610,
        minWidth: 600,
      ),
      decoration: dropdownContainerDecoration(),
      padding: dropdownPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: dropdown),
        ],
      ),
    );
  }
}
