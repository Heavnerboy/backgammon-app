import 'package:flutter/material.dart';

class AvatarWithName extends StatelessWidget {
  final String name;
  final String emojiOrInitial; // z. B. "🧠" oder "JS"
  final double avatarSize;
  final TextStyle? nameStyle;

  const AvatarWithName({
    super.key,
    required this.name,
    required this.emojiOrInitial,
    this.avatarSize = 42,
    this.nameStyle,
  });

  @override
  Widget build(BuildContext context) {
    final style = nameStyle ??
        Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: avatarSize / 2,
          child: Text(
            emojiOrInitial,
            style: TextStyle(fontSize: avatarSize * 0.5),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: avatarSize * 2.2,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
      ],
    );
  }
}