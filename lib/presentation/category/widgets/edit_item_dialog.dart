// Presentation - Edit Item Dialog
// Ermöglicht das Bearbeiten von Titel, Count, Beschreibung und Links eines bestehenden Items

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditItemDialog extends StatefulWidget {
  final String initialTitle;
  final int initialCount;
  final String? initialDescription;
  final List<String>? initialLinks;

  const EditItemDialog({
    super.key,
    required this.initialTitle,
    required this.initialCount,
    this.initialDescription,
    this.initialLinks,
  });

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController _titleController;
  late TextEditingController _countController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _countController = TextEditingController(text: '${widget.initialCount}');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _countController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop({
        'title': _titleController.text.trim(),
        'count': int.parse(_countController.text),
        'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Item bearbeiten'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titel
              TextFormField(
                controller: _titleController,
                autofocus: true,
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  hintText: 'z.B. Pizza',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte einen Titel eingeben';
                  }
                  if (value.length > 100) {
                    return 'Maximal 100 Zeichen erlaubt';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _save(),
              ),

              const SizedBox(height: 16),

              // Anzahl
              TextFormField(
                controller: _countController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'Anzahl',
                  hintText: '1',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                  helperText: 'Mindestens 1',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte eine Anzahl eingeben';
                  }
                  final count = int.tryParse(value);
                  if (count == null || count < 1) {
                    return 'Anzahl muss mindestens 1 sein';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _save(),
              ),

              const SizedBox(height: 16),

              // Beschreibung
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung (optional)',
                  hintText: 'z.B. Links oder Details zum Item...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
