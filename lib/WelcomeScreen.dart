import 'package:flutter/material.dart';
import 'ScanScreen.dart'; // Asegúrate de que la ruta sea correcta
import 'settingsScreen.dart'; // Asegúrate de que la ruta sea correcta
import 'ejercicios/TricepDetailScreen.dart'; // Asegúrate de que la ruta sea correcta

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Índice para el BottomNavigationBar

  List<int> _contadores = [0, 0, 0];
  List<double> _progresos = [0.0, 0.0, 0.0];

  // Función para incrementar el contador y el progreso
  void _incrementarContador(int index) {
    setState(() {
      if (_contadores[index] < 3) {
        _contadores[index]++;
        _progresos[index] = _contadores[index] / 3;
      }
    });
  }

  // Función para manejar la selección de la barra de navegación inferior
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navegar a las pantallas correspondientes según el índice seleccionado
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScanScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        // Hacemos scrollable la pantalla para evitar desbordamientos
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido de vuelta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Hola user',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),

              // ListView horizontal con las tarjetas
              Container(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white,
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ejercicio ${index + 1}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Contador: ${_contadores[index]}/3',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 10),
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                    begin: 0.0, end: _progresos[index]),
                                duration: Duration(milliseconds: 700),
                                builder: (context, value, child) {
                                  return LinearProgressIndicator(
                                    value: value,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey[200],
                                    color: Colors.black,
                                  );
                                },
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () => _incrementarContador(index),
                                child: Text('Incrementar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 30),

              // Sub-apartado "Técnica"
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Técnica',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Tarjeta de Tricep
              GestureDetector(
                onTap: () {
                  // Navegar a la pantalla de detalles de Tricep
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TricepDetailScreen()),
                  );
                },
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tricep',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(Icons.image,
                                size: 60, color: Colors.grey[600]),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Aquí va una breve descripción del ejercicio Tricep.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
