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

    final base = (widget.options == null || widget.options!.isEmpty)
        ? _defaultOptions
        : widget.options!;

    final set = <String>{...base, widget.initial};
    final rest = set.toList();

    rest.remove(widget.initial);
    _items = [widget.initial, ...rest];

    _value = widget.initial;
  }

  @override
  void didUpdateWidget(covariant AvatarPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial) {
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
      isExpanded: true,
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