import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';

class Routes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home'; 
  static const String calendar = '/calendar'; 


  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => SplashScreen(),
      welcome: (context) => WelcomeScreen(),
      login: (context) => LoginScreen(),
      register: (context) => RegisterScreen(),
      home: (context) => HomeScreen(),
      calendar: (context) => CalendarScreen(),
    };
  }
}