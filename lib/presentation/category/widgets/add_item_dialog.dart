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
            // Titel Eingabefeld mit Autocomplete
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                final text = textEditingValue.text.toLowerCase();
                return widget.suggestions.where((suggestion) =>
                    suggestion.toLowerCase().contains(text));
              },
              onSelected: (String selection) {
                _titleController.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                // Synchronisiere den internen Autocomplete-Controller mit unserem Controller
                _titleController.text = controller.text;
                _titleController.selection = controller.selection;
                
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'z.B. Pizza',
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
                  onChanged: (value) {
                    // Synchronisiere bei jedem Input
                    _titleController.text = value;
                  },
                  onFieldSubmitted: (_) => _submit(),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          dense: true,
                          title: Text(option),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
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
