import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FaceOverlay extends StatelessWidget {
  const FaceOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Dark overlay
        Container(
          color: Colors.black.withOpacity(0.5),
        ),

        /// Transparent oval cutout
        Center(
          child: Container(
            width: 220,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(140),
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
          ),
        ),

        /// Guide text
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Column(
            children: const [
              Text(
                "Align your face inside the frame",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Ensure good lighting & remove mask",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}