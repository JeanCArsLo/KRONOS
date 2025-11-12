import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/workout_area_screen.dart';
import 'screens/superior_exercises_screen.dart';
import 'screens/exercise_detail_screen.dart';
import 'screens/record_pr_screen.dart';
import '../models/ejercicios.dart';
import 'screens/ForgotPasswordScreen.dart';
import 'screens/Profile_Screen.dart';
import 'screens/edit_profile_screen.dart';

class Routes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password'; 
  static const String home = '/home'; 
  static const String calendar = '/calendar'; 
  static const String workouts = '/workouts'; 
  static const String bodyPartExercises = '/superior-exercises';
  static const String exerciseDetail = '/exercise-detail';
  static const String recordPR = '/record-pr';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => SplashScreen(),
      welcome: (context) => WelcomeScreen(),
      login: (context) => LoginScreen(),
      register: (context) => RegisterScreen(),
      forgotPassword: (context) =>ForgotPasswordScreen(),
      home: (context) => HomeScreen(),
      calendar: (context) => CalendarScreen(),
      workouts: (context) => WorkoutAreaScreen(),
      bodyPartExercises: (context) => BodyPartExercisesScreen(
        idPartesC: ModalRoute.of(context)?.settings.arguments as int?,
      ),
      recordPR: (context) => RecordPRScreen(),

      exerciseDetail: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as ZonaMuscular?;
        return ExerciseDetailScreen(
          idPartesC: args?.idPartesC ?? 1,
          idAreaM: args?.idAreaM ?? 1,
        );
      },
      editProfile: (context) => EditProfileScreen(), 
      profile: (context) => ProfileScreen(),
    };
  }
  
}