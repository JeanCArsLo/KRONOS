import 'package:flutter/material.dart';

class SuccessNotification {
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context, String message) {
    _removeCurrentOverlay();

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 15,
        right: 15,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color.fromARGB(255, 0, 255, 8), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 12,
                      color: const Color.fromARGB(255, 30, 30, 30),
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Icon(
                  Icons.check_circle,
                  color: const Color.fromARGB(255, 0, 200, 8),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);

    // Auto-cerrar después de 3 segundos
    Future.delayed(Duration(seconds: 3), () {
      _removeCurrentOverlay();
    });
  }

  static void showError(BuildContext context, String message) {
    _removeCurrentOverlay();

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 15,
        right: 15,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color.fromARGB(255, 255, 0, 0), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 12,
                      color: const Color.fromARGB(255, 30, 30, 30),
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Icon(
                  Icons.error,
                  color: const Color.fromARGB(255, 255, 0, 0),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);

    // Auto-cerrar después de 3 segundos
    Future.delayed(Duration(seconds: 3), () {
      _removeCurrentOverlay();
    });
  }

  static void _removeCurrentOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}