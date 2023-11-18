import 'package:flutter/material.dart';

class btnPet {
  static ButtonStyle imageButtonStyle = ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    minimumSize: Size(100, 100),
    padding: EdgeInsets.zero,
    backgroundColor: Color.fromARGB(255, 255, 255, 255), // Defina uma cor de fundo que forneça contraste suficiente
  );

  static BoxDecoration imageBoxDecoration(String imagePath) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      image: DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
      ),
    );
  }
}


