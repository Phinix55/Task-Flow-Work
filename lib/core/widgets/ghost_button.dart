import 'package:flutter/material.dart';

class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;

  const GhostButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: color != null 
          ? TextButton.styleFrom(foregroundColor: color)
          : null,
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
