import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  final bool isEditing;
  final String value;
  final bool isObscure;
  final ValueChanged<String>? onChanged;
  final VoidCallback toggleObscure;
  final int maxLength;

  const PasswordInput({
    super.key,
    required this.isEditing,
    required this.value,
    required this.isObscure,
    this.onChanged,
    required this.toggleObscure,
    this.maxLength = 20,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  late TextEditingController _controller;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _currentLength = widget.value.length;
  }

  @override
  void didUpdateWidget(covariant PasswordInput oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          enabled: widget.isEditing,
          obscureText: widget.isObscure,
          controller: _controller,
          maxLength: widget.maxLength,
          onChanged: widget.isEditing
              ? (val) {
            if (val.length <= widget.maxLength) {
              widget.onChanged?.call(val);
              setState(() => _currentLength = val.length);
            }
          }
              : null,
          style: TextStyle(
            color: widget.isEditing
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? Colors.grey[300]! : Colors.grey[600]!),
          ),
          decoration: InputDecoration(
            counterText: '', // hilangkan counter default
            hintText: widget.isEditing ? null : '********',
            hintStyle: TextStyle(
              color: widget.isEditing
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.grey[300]! : Colors.grey[600]!),
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[850]! : Colors.grey[100]!,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            suffixIcon: widget.isEditing
                ? IconButton(
              icon: Icon(
                widget.isObscure ? Icons.visibility_off : Icons.visibility,
                color: isDark ? Colors.white : Colors.black54,
              ),
              onPressed: widget.toggleObscure,
            )
                : null,
          ),
        ),
        if (widget.isEditing)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Text(
              '$_currentLength/${widget.maxLength}',
              style: TextStyle(
                fontSize: 12,
                color: _currentLength > widget.maxLength ? Colors.red : Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}