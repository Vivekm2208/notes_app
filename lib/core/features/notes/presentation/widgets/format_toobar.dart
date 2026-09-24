import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class FormatToolBar extends StatefulWidget {
  const FormatToolBar({
    super.key,
    required this.onFormat,
    required this.controller,
  });

  final ValueChanged<Attribute> onFormat;
  final QuillController controller;

  @override
  State<FormatToolBar> createState() => _FormatToolBarState();
}

class _FormatToolBarState extends State<FormatToolBar> {
  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final style = widget.controller.getSelectionStyle();

    // Text formatting
    final isBold = style.containsKey(Attribute.bold.key);
    final isItalic = style.containsKey(Attribute.italic.key);
    final isUnderline = style.containsKey(Attribute.underline.key);
    final isStrikeThrough = style.containsKey(Attribute.strikeThrough.key);

    // Headings
    final header = style.attributes[Attribute.header.key];

    final isH1 = header?.value == 1;
    final isH2 = header?.value == 2;
    final isH3 = header?.value == 3;

    // Lists
    final listAttribute = style.attributes[Attribute.list.key];

    final isBulletList = listAttribute?.value == 'bullet';
    final isNumberedList = listAttribute?.value == 'ordered';

    // Alignment
    final alignmentAttribute = style.attributes[Attribute.align.key];

    final isLeft = alignmentAttribute?.value == 'left';
    final isCenter = alignmentAttribute?.value == 'center';
    final isRight = alignmentAttribute?.value == 'right';
    final isJustify = alignmentAttribute?.value == 'justify';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // -------------------------
        // TEXT FORMATTING
        // -------------------------
        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.bold);
          },
          style: IconButton.styleFrom(
            backgroundColor: isBold ? colorScheme.primary : null,
            foregroundColor: isBold ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_bold),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.italic);
          },
          style: IconButton.styleFrom(
            backgroundColor: isItalic ? colorScheme.primary : null,
            foregroundColor: isItalic ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_italic),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.underline);
          },
          style: IconButton.styleFrom(
            backgroundColor: isUnderline ? colorScheme.primary : null,
            foregroundColor: isUnderline ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_underline),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.strikeThrough);
          },
          style: IconButton.styleFrom(
            backgroundColor: isStrikeThrough ? colorScheme.primary : null,
            foregroundColor: isStrikeThrough ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_strikethrough),
        ),

        // -------------------------
        // HEADINGS
        // -------------------------
        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.h1);
          },
          style: IconButton.styleFrom(
            backgroundColor: isH1 ? colorScheme.primary : null,
            foregroundColor: isH1 ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Text(
            'H1',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.h2);
          },
          style: IconButton.styleFrom(
            backgroundColor: isH2 ? colorScheme.primary : null,
            foregroundColor: isH2 ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Text(
            'H2',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.h3);
          },
          style: IconButton.styleFrom(
            backgroundColor: isH3 ? colorScheme.primary : null,
            foregroundColor: isH3 ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Text(
            'H3',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),

        // -------------------------
        // LISTS
        // -------------------------
        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.ul);
          },
          style: IconButton.styleFrom(
            backgroundColor: isBulletList ? colorScheme.primary : null,
            foregroundColor: isBulletList ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_list_bulleted),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.ol);
          },
          style: IconButton.styleFrom(
            backgroundColor: isNumberedList ? colorScheme.primary : null,
            foregroundColor: isNumberedList ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_list_numbered),
        ),

        // -------------------------
        // ALIGNMENT
        // -------------------------
        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.leftAlignment);
          },
          style: IconButton.styleFrom(
            backgroundColor: isLeft ? colorScheme.primary : null,
            foregroundColor: isLeft ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_align_left),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.centerAlignment);
          },
          style: IconButton.styleFrom(
            backgroundColor: isCenter ? colorScheme.primary : null,
            foregroundColor: isCenter ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_align_center),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.rightAlignment);
          },
          style: IconButton.styleFrom(
            backgroundColor: isRight ? colorScheme.primary : null,
            foregroundColor: isRight ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_align_right),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.justifyAlignment);
          },
          style: IconButton.styleFrom(
            backgroundColor: isJustify ? colorScheme.primary : null,
            foregroundColor: isJustify ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_align_justify),
        ),
      ],
    );
  }
}
