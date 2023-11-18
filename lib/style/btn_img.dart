import 'package:flutter/material.dart';

class btnImg extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double width; // Adicionado o parâmetro width

  const btnImg({
    required this.onPressed,
    required this.text,
    this.width = 300.0, // Valor padrão para width
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: width, // Defina o tamanho do botão aqui
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF862D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
