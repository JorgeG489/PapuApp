import 'package:flutter/material.dart';
import 'SignInScreen.dart';
import 'updateScreen.dart'; // Asegúrate de importar el archivo

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuración"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Actualizaciones"),
            onTap: () {
              // Redirige a la pantalla de actualizaciones
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdateScreen()),
              );
            },
          ),
          ListTile(
            title: Text("Cerrar sesión"),
            onTap: () {
              // Redirige al usuario a la pantalla de inicio de sesión
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
