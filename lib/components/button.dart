import 'package:flutter/material.dart';

class Buttonz extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const Buttonz({super.key,
  required this.text,
  required this.onTap,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 25),
      child: Center(
        child: Text(text),
      ),
      ),
    );
  }
}