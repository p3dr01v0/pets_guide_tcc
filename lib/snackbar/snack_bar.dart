import 'package:flutter/material.dart';

mostrarSnackBar({
  required BuildContext context,
  required String texto,
  bool isErro = true, required MaterialAccentColor cor
  }) {
    SnackBar snackBar = SnackBar  (
      content: Text(texto),
      backgroundColor: (isErro)? Colors.green: Colors.red,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

