import 'package:flutter/material.dart';

class TricepDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalle de Tricep")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ejercicio Tricep',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Aquí puedes agregar una descripción detallada sobre el ejercicio Tricep. Explica la técnica, los beneficios y cómo realizarlo correctamente.',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            SizedBox(height: 20),
            // Puedes agregar una imagen para el detalle de Tricep
            Image.asset('assets/tricep_example.jpg',
                height:
                    200), // Asegúrate de que esta imagen exista en el proyecto
          ],
        ),
      ),
    );
  }
}
