// rive_cache.dart
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class RiveCache {
  // Artboards separados
  static Artboard? artboardCalendario;
  static Artboard? artboardPopup;

  // Precargar animación para el calendario
  static Future<void> precargarMascotaCalendario() async {
    final data = await rootBundle.load('assets/mascota/PetanimU.riv');
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;

    artboard.addController(SimpleAnimation('Petidle'));

    artboardCalendario = artboard;
  }

  // Precargar animación para el popup
  static Future<void> precargarMascotaPopup() async {
    final data = await rootBundle.load('assets/mascota/PetanimU.riv');
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;

    artboard.addController(SimpleAnimation('PetCel'));

    artboardPopup = artboard;
  }
}
