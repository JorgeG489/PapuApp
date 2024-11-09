import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _bodyType = 'Ectomorph'; // Valor por defecto

  // Token de GitHub y la URL del repositorio (ajústalo según sea necesario)
  final String githubToken =
      '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'; // Tu token
  final String repoOwner = 'JorgeG489'; // Propietario del repositorio
  final String repoName = 'PapuApp'; // Nombre de tu repositorio
  final String filePath = 'register.json'; // Ruta del archivo en el repositorio

  // Función para guardar los datos en GitHub
  Future<void> saveUserDataToGitHub() async {
    final url = Uri.https(
        'api.github.com',
        '/repos/$repoOwner/$repoName/contents/$filePath',
        {'ref': 'main'}); // Especifica el branch 'main'

    // Obtén el contenido actual del archivo (si existe)
    final response = await http.get(url, headers: {
      'Authorization': 'token $githubToken',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      String base64Content =
          data['content']; // El contenido está codificado en base64

      // Limpiar el contenido base64 de saltos de línea o espacios adicionales
      base64Content = base64Content.replaceAll(RegExp(r'[\n\r]'), '');

      try {
        String decodedContent = utf8.decode(
            base64Decode(base64Content)); // Decodifica el contenido en Base64

        // Si el archivo está vacío, inicializa una lista vacía
        Map<String, dynamic> jsonData =
            decodedContent.isEmpty ? {'users': []} : jsonDecode(decodedContent);

        // Crear un nuevo usuario y agregarlo al archivo
        Map<String, String> newUser = {
          'email': _emailController.text,
          'password': _passwordController.text,
          'weight': _weightController.text,
          'height': _heightController.text,
          'age': _ageController.text,
          'bodyType': _bodyType,
        };

        jsonData['users'].add(newUser);

        // Codificar nuevamente a base64
        final encodedData = base64Encode(utf8.encode(jsonEncode(jsonData)));

        // Actualizar el archivo en GitHub
        final sha =
            data['sha']; // Obtén el sha del archivo para la actualización
        final updateResponse = await http.put(url,
            headers: {
              'Authorization': 'token $githubToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'message': 'Nuevo registro de usuario',
              'content': encodedData,
              'sha': sha,
            }));

        if (updateResponse.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Usuario registrado correctamente')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al registrar al usuario')));
        }
      } catch (e) {
        print("Error al decodificar el contenido base64: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al procesar los datos')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo obtener el archivo')));
    }
  }

  // Función para registrar al usuario
  void registerUser() {
    saveUserDataToGitHub();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(labelText: 'Peso'),
            ),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(labelText: 'Altura'),
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Edad'),
            ),
            DropdownButton<String>(
              value: _bodyType,
              onChanged: (String? newValue) {
                setState(() {
                  _bodyType = newValue!;
                });
              },
              items: <String>['Ectomorph', 'Mesomorph', 'Endomorph']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: registerUser,
              child: Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
