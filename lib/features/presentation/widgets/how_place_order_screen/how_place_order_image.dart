import 'package:flutter/material.dart';

class HowPlaceOrderImage extends StatelessWidget {
  const HowPlaceOrderImage(
      {super.key, required this.imagePath, required this.height});

  final String imagePath;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(imagePath,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          alignment: AlignmentDirectional.topCenter),
    );
  }
}
