import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GitHubService {
  final String repoOwner = 'tu_usuario'; // Tu nombre de usuario en GitHub
  final String repoName = 'PapuApp'; // El nombre de tu repositorio
  final String filePath =
      'register.json'; // Ruta del archivo JSON en el repositorio
  final String token = dotenv.env[
      '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']!; // Obtener el token del archivo .env

  // Función para obtener el contenido del archivo register.json desde GitHub
  Future<Map<String, dynamic>> getFileContent() async {
    final url =
        'https://api.github.com/repos/$repoOwner/$repoName/contents/$filePath';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'token $token',
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      // Decodificar el archivo base64
      String content = data['content'];
      String decodedContent = utf8.decode(base64Decode(content));
      return jsonDecode(decodedContent);
    } else {
      throw Exception('Error al obtener el archivo de GitHub');
    }
  }

  // Función para actualizar el archivo register.json en GitHub
  Future<void> updateFile(Map<String, dynamic> newData, String sha) async {
    final url =
        'https://api.github.com/repos/$repoOwner/$repoName/contents/$filePath';
    final base64Content = base64Encode(utf8.encode(jsonEncode(newData)));

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'token $token',
      },
      body: jsonEncode({
        'message': 'Actualizar registro de usuario',
        'content': base64Content,
        'sha':
            sha, // SHA del archivo para verificar que estamos actualizando el correcto
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el archivo en GitHub');
    }
  }

  // Función principal para registrar un usuario y actualizar el archivo
  Future<void> registerUser(Map<String, dynamic> newUser) async {
    // Obtener el contenido actual del archivo register.json
    Map<String, dynamic> currentData = await getFileContent();

    // Agregar el nuevo usuario a la lista
    currentData['users'].add(newUser);

    // Obtener el SHA del archivo para poder actualizarlo
    String sha = currentData['sha'];

    // Actualizar el archivo en GitHub con los nuevos datos
    await updateFile(currentData, sha);
  }
}
