import 'package:flutter/material.dart';
import 'package:mairie_ipad/components/header.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets
                .only(), // Ajoute un padding pour décaler l'image
            child: Image.asset('lib/assets/ales.jpg', width: 250, height: 250),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              'Bienvenue à la Mairie d\'Alès',
              style: TextStyle(fontSize: 24.0),
            ),
          ),
        ],
      ),
    );
  }
}
