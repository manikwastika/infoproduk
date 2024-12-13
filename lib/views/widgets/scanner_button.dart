import 'package:flutter/material.dart';

class ScannerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;

  const ScannerButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData buttonIcon =
        text == 'Scan Image' ? Icons.image_rounded : Icons.keyboard;

    return SizedBox(
      width: width,
      height: 51,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 226, 226, 226),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  buttonIcon,
                  size: 20,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                Text(text),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
