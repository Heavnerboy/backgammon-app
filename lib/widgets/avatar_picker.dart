import 'package:flutter/material.dart';

class AvatarPicker extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onChanged;
  final List<String>? options; // optional: eigene Liste übergeben

  const AvatarPicker({
    super.key,
    required this.initial,
    required this.onChanged,
    this.options,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  late String _value;
  late List<String> _items;

  static const List<String> _defaultOptions = [
    '😀','😎','🥳','🤓','🧠','🦊','🐶','🐱','🐻','🐼',
    '🐨','🐯','🦁','🐸','🐵','🐰','🐹','🦄','🐙','🐠',
    '⚫','⚪','🔴','🟠','🟡','🟢','🔵','🟣','🟤',
  ];

  @override
  void initState() {
    super.initState();

    // 1) Grundliste bestimmen (extern übergeben oder Defaults)
    final base = (widget.options == null || widget.options!.isEmpty)
        ? _defaultOptions
        : widget.options!;

    // 2) initial sicherstellen: wenn nicht in Liste, hinzufügen
    final set = <String>{...base, widget.initial};

    // 3) deterministische Reihenfolge (initial zuerst, dann Rest)
    final rest = set.toList();
    // initial nach vorne ziehen
    rest.remove(widget.initial);
    _items = [widget.initial, ...rest];

    // 4) garantierter, gültiger Wert
    _value = widget.initial;
  }

  @override
  void didUpdateWidget(covariant AvatarPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial) {
      // Falls von außen ein anderer initial reinkommt -> sicher aufnehmen
      if (!_items.contains(widget.initial)) {
        _items = [widget.initial, ..._items.where((e) => e != widget.initial)];
      }
      _value = widget.initial;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _value,
      isExpanded: true, // verhindert seitlichen Overflow
      underline: const SizedBox.shrink(),
      items: _items
          .map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(e, style: const TextStyle(fontSize: 22)),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        setState(() => _value = v);
        widget.onChanged(v);
      },
    );
  }
}