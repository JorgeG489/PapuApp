import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String _productName = '';
  String _calories = '';
  String _carbohydrates = '';

  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();

      if (result.rawContent.isNotEmpty) {
        _productName = result.rawContent; // Usar el código escaneado como nombre del producto
        await _fetchProductInfo(result.rawContent); // Buscar información del producto
      } else {
        _showError('No se pudo escanear el código de barras. Intente nuevamente.');
      }
    } catch (e) {
      _showError('Error al escanear el código de barras: $e');
    }
  }

  Future<void> _fetchProductInfo(String barcode) async {
    try {
      // API 1: Open Food Facts
      final response1 = await http.get(Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'));
      
      if (response1.statusCode == 200) {
        final data1 = jsonDecode(response1.body);
        if (data1['product'] != null) {
          _updateProductInfo(data1['product']);
          return; // Salir si se encontró información en la primera API
        }
      }

      // API 2: UPCItemDB
      final response2 = await http.get(Uri.parse('https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode'));
      
      if (response2.statusCode == 200) {
        final data2 = jsonDecode(response2.body);
        if (data2['items'] != null && data2['items'].isNotEmpty) {
          _updateProductInfo(data2['items'][0]); // Actualiza la información del producto
          return; // Salir si se encontró información en la segunda API
        }
      }

      // API 3: Edamam (requiere token, pero puedes usarla si tienes)
      final response3 = await http.get(Uri.parse('https://api.edamam.com/api/food-database/v2/parser?upc=$barcode&app_id=YOUR_APP_ID&app_key=YOUR_APP_KEY'));

      if (response3.statusCode == 200) {
        final data3 = jsonDecode(response3.body);
        if (data3['hints'] != null && data3['hints'].isNotEmpty) {
          _updateProductInfo(data3['hints'][0]['food']); // Actualiza la información del producto
          return; // Salir si se encontró información en la tercera API
        }
      }

      // Si no se encontró información en ninguna API
      _showError('No se encontró información para el código de barras: $barcode');

    } catch (e) {
      _showError('Error al obtener información del producto: $e');
    }
  }

  void _updateProductInfo(dynamic product) {
    setState(() {
      _productName = product['product_name'] ?? 'Nombre no disponible';
      _calories = product['nutriments'] != null ? (product['nutriments']['ENERC_KCAL'] ?? 'No disponible').toString() : 'No disponible';
      _carbohydrates = product['nutriments'] != null ? (product['nutriments']['CHOCDF'] ?? 'No disponible').toString() : 'No disponible';
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escanear Código de Barras')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _scanBarcode,
              child: Text('Escanear Código de Barras'),
            ),
            SizedBox(height: 20),
            Text('Producto: $_productName'),
            Text('Calorías: $_calories'),
            Text('Carbohidratos: $_carbohydrates'),
          ],
        ),
      ),
    );
  }
}
