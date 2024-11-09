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
  String _imageUrl = '';
  bool _isLoading = false;

  // Método para escanear el código de barras
  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();

      if (result.rawContent.isNotEmpty) {
        setState(() {
          _isLoading = true;
        });

        _productName = result.rawContent;
        await _fetchProductInfo(result.rawContent);
        await _fetchProductImage(result.rawContent);
      } else {
        _showError(
            'No se pudo escanear el código de barras. Intente nuevamente.');
      }
    } catch (e) {
      _showError('Error al escanear el código de barras: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para obtener la información del producto
  Future<void> _fetchProductInfo(String barcode) async {
    final apis = [
      {'url': 'https://world.openfoodfacts.org/api/v0/product/$barcode.json'},
      {'url': 'https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode'},
      {
        'url':
            'https://api.edamam.com/api/food-database/v2/parser?upc=$barcode&app_id=YOUR_APP_ID&app_key=YOUR_APP_KEY'
      }
    ];

    for (var api in apis) {
      try {
        final response = await http.get(Uri.parse(api['url']!));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (_updateProductInfoFromData(data)) return;
        }
      } catch (e) {
        _showError('Error al obtener información del producto: $e');
        return;
      }
    }

    _showError('No se encontró información para el código de barras: $barcode');
  }

  // Método para procesar la información del producto
  bool _updateProductInfoFromData(dynamic data) {
    if (data.containsKey('product')) {
      _updateProductInfo(data['product']);
      return true;
    } else if (data.containsKey('items') && data['items'].isNotEmpty) {
      _updateProductInfo(data['items'][0]);
      return true;
    } else if (data.containsKey('hints') && data['hints'].isNotEmpty) {
      _updateProductInfo(data['hints'][0]['food']);
      return true;
    }
    return false;
  }

  // Método para actualizar la información del producto
  void _updateProductInfo(dynamic product) {
    setState(() {
      _productName = product['product_name'] ?? 'Nombre no disponible';
      _calories = _parseCalories(product);
      _carbohydrates = _parseNutrient(product, 'carbohydrates_value');
    });
  }

  // Método para parsear las calorías
  String _parseCalories(dynamic product) {
    final energyKcal = product['nutriments']?['energy-kcal'];
    final energyKcalServing = product['nutriments']?['energy-kcal_serving'];

    if (energyKcal != null) {
      return 'Por 100g: $energyKcal kcal\nPor porción: ${energyKcalServing ?? 'No disponible'} kcal';
    }
    return 'No disponible';
  }

  // Método para parsear otros nutrientes
  String _parseNutrient(dynamic product, String key) {
    return product['nutriments']?[key]?.toString() ?? 'No disponible';
  }

  // Método para mostrar errores
  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Método para obtener la imagen del producto usando Google Custom Search
  Future<void> _fetchProductImage(String query) async {
    final apiKey = 'AIzaSyD5pdmo1yOZdUWkTq6SWg6k_JHRYkhV_mc'; // Tu clave de API
    final cx = '24e1414fa30aa4df8'; // ID del motor de búsqueda
    final url =
        'https://www.googleapis.com/customsearch/v1?q=$query&searchType=image&key=$apiKey&cx=$cx';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          setState(() {
            _imageUrl = data['items'][0]['link']; // URL de la imagen
          });
        } else {
          _showError('No se encontraron imágenes para el producto.');
        }
      } else {
        _showError('Error al obtener la imagen: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error al obtener la imagen del producto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Escanear Código de Barras'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botón de escaneo
                    ElevatedButton(
                      onPressed: _scanBarcode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .purple, // Usamos backgroundColor en lugar de primary
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Escanear Código de Barras',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Nombre del producto
                    _buildInfoCard('Producto', _productName),
                    SizedBox(height: 10),

                    // Calorías
                    _buildInfoCard('Calorías', _calories),
                    SizedBox(height: 10),

                    // Carbohidratos
                    _buildInfoCard('Carbohidratos', _carbohydrates),
                    SizedBox(height: 20),

                    // Imagen del producto
                    _imageUrl.isNotEmpty
                        ? Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 5)
                              ],
                            ),
                            child: Image.network(_imageUrl,
                                height: 200, width: 200),
                          )
                        : Container(),

                    SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  // Método para construir tarjetas de información
  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.purple)),
        ],
      ),
    );
  }
}
