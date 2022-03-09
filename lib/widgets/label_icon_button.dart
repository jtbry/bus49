import 'package:flutter/material.dart';

class LabelIconButton extends StatelessWidget {
  final IconData iconData;
  final Color color;
  final String labelText;
  final Function() onPressed;

  const LabelIconButton({
    Key? key,
    required this.iconData,
    required this.color,
    required this.labelText,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onPressed,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Column(
            children: [
              Icon(
                iconData,
                color: color,
              ),
              Text(
                labelText,
                style: TextStyle(color: color),
              )
            ],
          ),
        ),
      ),
    );
  }
}
