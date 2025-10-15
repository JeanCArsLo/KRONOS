import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToWelcome();
  }

  _navigateToWelcome() async {
    await Future.delayed(Duration(seconds: 3)); // Espera 3 segundos
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'KRONOS',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo con altura limitada al 82%
          Container(
            height: MediaQuery.of(context).size.height * 0.82,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/welcom.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay con gradiente para difuminar la parte inferior
          Container(
            height: MediaQuery.of(context).size.height * 0.82, // Mismo height que la imagen
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent, // Sin color en la parte superior
                  Colors.black.withOpacity(0.5), // Difuminado oscuro en la parte inferior
                ],
                stops: [0.7, 1.0], // El difuminado comienza al 70% y se completa al 100%
              ),
            ),
          ),
          // Contenido superpuesto
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Tu viaje hacia una mejor versión empieza hoy, y no lo harás solo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 10, 10, 10),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '¡Bienvenido a Kronos Fit!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 10, 10, 10),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      // Botón "CREAR CUENTA"
                      ElevatedButton(
                        onPressed: () {
                          // Acción al presionar el botón
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 11, 80, 136),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(
                          'CREAR CUENTA',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Enlace "Ya tengo cuenta. Iniciar sesión"
                      GestureDetector(
                        onTap: () {
                          // Acción para iniciar sesión
                        },
                        child: Text(
                          'Ya tengo cuenta. Iniciar sesión.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}