import 'package:flutter/material.dart';

InputDecoration caixaTxt(String label) {
  return InputDecoration(
    label: Text(label),
    hintText: label,
    filled: true,
    fillColor: Colors.white, // cor interna da caixa
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: const BorderSide(color: Color(0xFF10428B), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: const BorderSide(
          color: Colors.lightBlue, width: 1), // Defina a cor desejada aqui
    ),
    contentPadding: const EdgeInsets.symmetric(
        vertical: 15.0, horizontal: 15.0), // vertical altura,
  );
}
