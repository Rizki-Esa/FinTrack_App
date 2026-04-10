import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final bool isEditing;
  final String value;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int maxLength;
  final String? labelText;
  final String? hintText;

  // ⭐ NEW — optional configs
  final TextInputType keyboardType;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool forceLowerCase;

  const TextInput({
    super.key,
    required this.isEditing,
    required this.value,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength = 100,
    this.labelText,
    this.hintText,

    // ⭐ defaults aman
    this.keyboardType = TextInputType.text,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.forceLowerCase = false,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  late TextEditingController _controller;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _currentLength = widget.value.length;
  }

  @override
  void didUpdateWidget(covariant TextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      _currentLength = widget.value.length;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChange(String val) {
    if (!widget.isEditing) return;

    String processed = val;

    // ⭐ Lowercase otomatis jika diaktifkan
    if (widget.forceLowerCase) {
      processed = val.toLowerCase();

      if (processed != val) {
        _controller.value = _controller.value.copyWith(
          text: processed,
          selection: TextSelection.collapsed(offset: processed.length),
        );
      }
    }

    if (processed.length <= widget.maxLength) {
      widget.onChanged?.call(processed);
      setState(() => _currentLength = processed.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          enabled: widget.isEditing,
          controller: _controller,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          onChanged: widget.isEditing ? _handleChange : null,
          style: TextStyle(
            color: widget.isEditing
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? Colors.grey[300]! : Colors.grey[600]!),
          ),
          decoration: InputDecoration(
            counterText: '',
            labelText: widget.labelText,
            hintText: widget.isEditing ? null : widget.value,
            hintStyle: TextStyle(
              color: widget.isEditing
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.grey[300]! : Colors.grey[600]!),
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[850]! : Colors.grey[100]!,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        // ⭐ Custom counter
        if (widget.isEditing)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Text(
              '$_currentLength/${widget.maxLength}',
              style: TextStyle(
                fontSize: 12,
                color:
                _currentLength > widget.maxLength ? Colors.red : Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}