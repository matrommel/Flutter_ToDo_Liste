// Presentation - Dialog zum Hinzufügen eines Items

import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {
  final List<String> suggestions;

  const AddItemDialog({super.key, this.suggestions = const []});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  int _count = 1;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'title': _titleController.text.trim(),
        'count': _count,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Neues Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titel Eingabefeld
            TextFormField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'z.B. Milch',
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte einen Namen eingeben';
                }
                if (value.length > 100) {
                  return 'Maximal 100 Zeichen';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            if (widget.suggestions.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Vorschläge',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.suggestions
                    .map(
                      (s) => ActionChip(
                        label: Text(s),
                        onPressed: () {
                          _titleController.text = s;
                          _titleController.selection = TextSelection.fromPosition(
                            TextPosition(offset: s.length),
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            // Anzahl Auswahl
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Anzahl:'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _count > 1
                          ? () => setState(() => _count--)
                          : null,
                    ),
                    Text(
                      '$_count',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => _count++),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Hinzufügen'),
        ),
      ],
    );
  }
}
