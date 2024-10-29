import 'dart:convert';
import 'dart:io'; // Asegúrate de que esta línea esté presente
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String currentVersion = "1.0.0"; // Versión actual de la app
  String? latestVersion; // Última versión disponible
  bool downloading = false;
  String downloadProgress = "";

  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showSnackbar('Sin conexión a Internet');
      return;
    }

    final String url = "https://raw.githubusercontent.com/JorgeG489/appMobile2/main/update.json";

    try {
      final response = await Dio().get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.data);

        setState(() {
          latestVersion = data['version'];
        });

        if (latestVersion != currentVersion) {
          _showUpdateDialog(data['url']);
        }
      } else {
        _showSnackbar('Error al verificar actualizaciones: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error al verificar actualizaciones: $e');
    }
  }

  void _showUpdateDialog(String apkUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nueva actualización disponible'),
          content: Text('Versión $latestVersion está disponible. ¿Deseas actualizar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _requestPermissionsAndDownload(apkUrl);
              },
              child: Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestPermissionsAndDownload(String apkUrl) async {
    var storagePermission = await Permission.storage.request();

    if (storagePermission.isGranted) {
      await downloadAndInstallApk(apkUrl);
    } else {
      _showSnackbar('Permisos de almacenamiento denegados');
    }
  }

  Future<void> downloadAndInstallApk(String apkUrl) async {
    try {
      setState(() {
        downloading = true;
      });

      Directory? appDocDir = await getExternalStorageDirectory();
      String apkPath = "${appDocDir!.path}/app-release.apk";

      await Dio().download(apkUrl, apkPath, onReceiveProgress: (received, total) {
        if (total != -1) {
          setState(() {
            downloadProgress = (received / total * 100).toStringAsFixed(0) + "%";
          });
        }
      });

      setState(() {
        downloading = false;
        downloadProgress = "Descarga completa";
      });

      // Abre el archivo APK
      OpenFile.open(apkPath);
    } catch (e) {
      if (e is DioError) {
        _showSnackbar('Error de red al descargar: ${e.message}');
      } else {
        _showSnackbar('Error desconocido: $e');
      }
    }
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Versión actual: $currentVersion'),
            if (latestVersion != null && latestVersion != currentVersion)
              Text('Nueva versión disponible: $latestVersion'),
            if (downloading) 
              Column(
                children: [
                  CircularProgressIndicator(),
                  Text('Descargando: $downloadProgress'),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkForUpdate,
              child: Text('Buscar actualizaciones'),
            ),
          ],
        ),
      ),
    );
  }
}
