import 'package:flutter/material.dart';

class ReadOnlyTo extends StatelessWidget {
  final String hintText;
  final bool tago;
  final TextEditingController controller;

  const ReadOnlyTo({
    super.key,
    required this.hintText,
    required this.tago,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280, 
      height: 35,
      child: TextField(
        obscureText: tago,
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 31, 190, 187),
            ),
          ),
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color.fromARGB(255, 33, 146, 15)),
        ),
      ),
    );
  }
}
