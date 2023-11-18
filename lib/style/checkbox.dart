import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final String text;
  final bool value;
  final Function(bool?) onChanged;

  const CustomCheckbox(
      {super.key,
      required this.text,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345,
      height: 50,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 243, 236),
        //borderRadius: BorderRadius.circular(25.0), // adiciona um border radius
        //border: Border.all(color: Colors.black, width: 1.0), // adiciona uma borda em volta do container
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            checkColor: Colors.black,
            activeColor: const Color(0xFFFF862D),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
