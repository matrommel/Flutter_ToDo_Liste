import 'package:flutter/material.dart';
import 'package:matzo/core/services/biometric_auth_service.dart';

class BiometricProtectionDialog extends StatefulWidget {
  final String categoryName;
  final bool isCurrentlyProtected;
  final Function(bool) onProtectionChanged;

  const BiometricProtectionDialog({
    Key? key,
    required this.categoryName,
    required this.isCurrentlyProtected,
    required this.onProtectionChanged,
  }) : super(key: key);

  @override
  State<BiometricProtectionDialog> createState() =>
      _BiometricProtectionDialogState();
}

class _BiometricProtectionDialogState extends State<BiometricProtectionDialog> {
  late bool _isProtected;
  bool _isBiometricAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isProtected = widget.isCurrentlyProtected;
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await BiometricAuthService.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _isBiometricAvailable = available;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AlertDialog(
        title: const Text('Wird überprüft...'),
        content: const CircularProgressIndicator(),
      );
    }

    if (!_isBiometricAvailable && _isProtected) {
      return AlertDialog(
        title: const Text('Biometrie nicht verfügbar'),
        content: const Text(
          'Biometrischer Schutz ist auf diesem Gerät nicht verfügbar. '
          'Bitte aktivieren Sie zuerst Biometrische Authentifizierung in den Systemeinstellungen.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _isProtected = false);
              Navigator.of(context).pop();
            },
            child: const Text('Deaktivieren'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text('Schutz für "${widget.categoryName}"'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isBiometricAvailable)
            ListTile(
              title: const Text('Biometrischer Schutz'),
              subtitle: const Text(
                'Diese Kategorie mit Fingerabdruck oder Gesicht schützen',
              ),
              trailing: Switch(
                value: _isProtected,
                onChanged: (value) {
                  setState(() => _isProtected = value);
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Biometrische Authentifizierung ist auf diesem Gerät nicht verfügbar.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onProtectionChanged(_isProtected);
            Navigator.of(context).pop();
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
