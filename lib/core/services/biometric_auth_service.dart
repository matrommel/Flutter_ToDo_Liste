// Biometric Authentication Service

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static BuildContext? _lastContext;

  /// Überprüft, ob Biometrie auf dem Gerät verfügbar ist
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _auth.canCheckBiometrics;
      print('BiometricAuth - canCheckBiometrics: $isAvailable');
      
      final availableBiometrics = await _auth.getAvailableBiometrics();
      print('BiometricAuth - availableBiometrics: $availableBiometrics');
      
      return isAvailable && availableBiometrics.isNotEmpty;
    } catch (e) {
      print('BiometricAuth - isBiometricAvailable Error: $e');
      return false;
    }
  }

  /// Liefert Liste der verfügbaren Biometrie-Typen
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Führt Biometrische Authentifizierung durch
  static Future<bool> authenticate({
    String localizedReason = 'Authentifizieren Sie sich, um fortzufahren',
    bool stickyAuth = true,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      print('BiometricAuth - isAvailable: $isAvailable');
      
      if (!isAvailable) {
        print('BiometricAuth - Biometrie nicht verfügbar, zeige PIN-Dialog...');
        // Fallback: Zeige einfachen PIN-Dialog
        return await _showSimplePinDialog();
      }

      final result = await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: false, // Erlaube auch PIN/Passwort als Fallback
        ),
      );
      print('BiometricAuth - authenticate result: $result');
      return result;
    } catch (e) {
      print('BiometricAuth Error: $e');
      // Fallback bei Error
      return await _showSimplePinDialog();
    }
  }

  /// Context für Dialog setzen (wird von home_screen aufgerufen)
  static void setContext(BuildContext context) {
    _lastContext = context;
  }

  /// PIN-Dialog als Fallback wenn Biometrie nicht verfügbar
  static Future<bool> _showPinDialog(String categoryName) async {
    print('BiometricAuth - _showPinDialog für "$categoryName"');
    
    try {
      final result = await _auth.authenticate(
        localizedReason: 'Authentifizieren Sie sich, um "$categoryName" zu öffnen',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      print('BiometricAuth - _showPinDialog result: $result');
      return result;
    } catch (e) {
      print('BiometricAuth - _showPinDialog Error: $e');
      return false;
    }
  }

  /// Einfacher PIN-Dialog als Fallback
  static Future<bool> _showSimplePinDialog() async {
    print('BiometricAuth - Fallback PIN Dialog wird angezeigt');
    return await _showPinDialog('Kategorie') ?? false;
  }

  /// Authentifizierung mit Custom-Meldung für Kategorie
  static Future<bool> authenticateForCategory(String categoryName) async {
    try {
      print('BiometricAuth - authenticateForCategory für "$categoryName"');
      print('BiometricAuth - Starte Authentifizierung...');
      
      // Versuche direkt zu authentifizieren mit biometricOnly: false
      // Das erlaubt dem System, Biometrie ODER Passwort zu verwenden
      final result = await _auth.authenticate(
        localizedReason: 'Authentifizieren Sie sich, um "$categoryName" zu öffnen',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Wichtig: Erlaubt Fallback zu Passwort
        ),
      );
      
      print('BiometricAuth - authenticateForCategory result: $result');
      return result;
    } on PlatformException catch (e) {
      print('BiometricAuth - PlatformException: ${e.code} - ${e.message}');
      
      // Bestimmte Fehler ignorieren (z.B. "NotAvailable", "LockOut")
      if (e.code == 'NotAvailable' || e.code == 'userCancelled') {
        print('BiometricAuth - Benutzer hat abgebrochen');
        return false;
      }
      
      if (_lastContext != null) {
        ScaffoldMessenger.of(_lastContext!).showSnackBar(
          SnackBar(
            content: Text('Fehler: ${e.message}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    } catch (e) {
      print('BiometricAuth - authenticateForCategory Error: $e');
      
      if (_lastContext != null) {
        ScaffoldMessenger.of(_lastContext!).showSnackBar(
          SnackBar(
            content: Text('Authentifizierung fehlgeschlagen: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
  }

  /// Stoppt laufende Authentifizierung
  static Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } catch (e) {
      // Ignorieren
    }
  }
}
