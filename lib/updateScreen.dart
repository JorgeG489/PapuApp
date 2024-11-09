import 'dart:convert'; // Para trabajar con JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // Importar el paquete `url_launcher`

class UpdateScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<UpdateScreen> {
  String currentVersion = "0.007"; // La versión actual de la app
  String latestVersion =
      ""; // Para guardar la versión más reciente desde el JSON
  String updateUrl = "https://www.google.com"; // Enlace conocido para probar
  bool isUpdating = false; // Estado de la actualización

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  // Función para obtener los datos del archivo JSON en línea
  Future<void> _checkForUpdates() async {
    setState(() {
      isUpdating = true; // Mostrar un indicador de carga
    });

    try {
      // Realizar la solicitud HTTP para obtener el JSON
      final response = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/JorgeG489/PapuApp/main/updates.json'));

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, analizar el JSON
        final data = json.decode(response.body);

        setState(() {
          latestVersion = data['version']; // Obtener la versión desde el JSON
          updateUrl = data['url']; // Obtener el enlace de la actualización
          isUpdating = false; // Ocultar el indicador de carga
        });
      } else {
        setState(() {
          isUpdating =
              false; // Si hubo error en la solicitud, ocultar indicador
        });
        // Mostrar error si la solicitud no fue exitosa
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al obtener actualizaciones')));
      }
    } catch (e) {
      setState(() {
        isUpdating = false; // Ocultar indicador de carga en caso de error
      });
      // Manejar cualquier error de conexión
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error de conexión')));
    }
  }

  // Función para lanzar la URL de actualización
  Future<void> _launchURL() async {
    final Uri url = Uri.parse(updateUrl); // Usa el URL conocido de prueba
    if (await canLaunchUrl(url)) {
      // Asegúrate de que el enlace pueda abrirse
      await launchUrl(url); // Lanza la URL
    } else {
      throw 'No se pudo abrir el enlace';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuraciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actualizaciones',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            isUpdating
                ? Center(
                    child:
                        CircularProgressIndicator()) // Mostrar el indicador de carga
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Versión actual: $currentVersion',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      if (latestVersion.isNotEmpty)
                        Text(
                          'Versión más reciente: $latestVersion',
                          style: TextStyle(fontSize: 18, color: Colors.blue),
                        ),
                      if (latestVersion.isNotEmpty &&
                          currentVersion != latestVersion)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton(
                            onPressed:
                                _launchURL, // Aquí llama a la función que lanza la URL
                            child: Text('Actualizar ahora'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .blueAccent, // Corregido a `backgroundColor`
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
