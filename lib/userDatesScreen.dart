import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart'; // Importa la clase User

class UserDataScreen extends StatefulWidget {
  @override
  _UserDataScreenState createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  List<User> users = [];

  // Función para cargar los usuarios desde register.json
  Future<void> loadUserData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/register.json');

    if (await file.exists()) {
      String contents = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(contents);

      // Convertir los datos JSON en objetos User
      List<dynamic> usersJson = jsonData['users'];
      users = usersJson.map((userJson) => User.fromJson(userJson)).toList();

      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Datos de Usuario')),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          User user = users[index];
          return ListTile(
            title: Text(user.email),
            subtitle: Text(
                'Edad: ${user.age}, Peso: ${user.weight}, Tipo de cuerpo: ${user.bodyType}'),
          );
        },
      ),
    );
  }
}
