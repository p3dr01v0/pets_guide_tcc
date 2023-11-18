import 'package:flutter/material.dart';

Widget btnDrop(String value, List<String> items, void Function(String?) onChanged) {
  return DropdownButton<String>(
    value: value,
    onChanged: onChanged,
    items: items.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          value,
          style: const TextStyle(color: Colors.black, fontSize: 16.0), // Estilo do texto no botão
        ),
      );
    }).toList(),
    style: const TextStyle(color: Colors.black, fontSize: 16.0), // Estilo do texto no botão
    isExpanded: true, // Para ocupar o máximo de espaço horizontalmente
    underline: Container(
      height: 1,
      color: Colors.black,
    ), // Adiciona uma linha na parte inferior do botão
    dropdownColor: Colors.white, // cor interna da lista suspensa
  );
}
