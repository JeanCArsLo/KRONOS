import 'package:flutter/material.dart';
import '../routes.dart';

class MainLayout extends StatefulWidget {
  final Widget child; // ← El contenido que cambia
  final int currentIndex; // ← Para saber qué icono marcar

  const MainLayout({
    super.key,
    required this.child,
    this.currentIndex = 0,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ========== LOGO "KRONOS FIT" (FIJO) ==========
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'KRONOS FIT',
                    style: TextStyle(
                      fontFamily: 'AldrichRegular',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey[300]),

            // ========== CONTENIDO QUE CAMBIA ==========
            Expanded(
              child: widget.child,
            ),

            // ========== BARRA DE NAVEGACIÓN INFERIOR (FIJA) ==========
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey..withValues(alpha: 0x33),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: widget.currentIndex,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: Color(0xFF003D82),
                unselectedItemColor: Colors.grey,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                elevation: 0,
                onTap: (index) {
                  // ========== NAVEGACIÓN ENTRE PANTALLAS ==========
                  switch (index) {
                    case 0:
                      //Navigator.pushReplacementNamed(context, Routes.);
                      break;
                    case 1:
                      // Navigator.pushReplacementNamed(context, Routes.);
                      break;
                    case 2:
                      Navigator.pushReplacementNamed(context, Routes.home);
                      break;
                    case 3:
                      
                      // Navigator.pushReplacementNamed(context, Routes.workouts);
                      break;
                    case 4:
                      // Navigator.pushReplacementNamed(context, Routes.profile);
                      break;
                  }
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today_outlined),
                    activeIcon: Icon(Icons.calendar_today),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.military_tech_outlined),
                    activeIcon: Icon(Icons.military_tech),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.fitness_center_outlined),
                    activeIcon: Icon(Icons.fitness_center),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}