import 'package:flutter/material.dart';

class CardStyle {
  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  static BoxDecoration circleDecoration(String imageUrl) {
    return BoxDecoration(
      shape: BoxShape.circle,
      image: DecorationImage(
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
      ),
    );
  }
}
