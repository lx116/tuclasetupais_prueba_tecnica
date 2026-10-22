import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';

/// Reusable search field.
///
/// [onChanged] is called with the text once typing pauses for [debounce], right
/// away when the user submits or clears. [value] is the text the owner holds
/// (for example, read from the URL): when it changes from outside the field
/// follows it, unless the user is in the middle of typing.
class SearchInput extends StatefulWidget {
  const SearchInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.hintText = 'Buscar',
    this.debounce = const Duration(milliseconds: 300),
    this.fontSize = 15,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String hintText;
  final Duration debounce;
  final double fontSize;

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  )..addListener(_onControllerChanged);
  Timer? _timer;

  bool get _typing => _timer?.isActive ?? false;

  @override
  void didUpdateWidget(SearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value &&
        widget.value != _controller.text &&
        !_typing) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  // Rebuilds to show or hide the clear button.
  void _onControllerChanged() => setState(() {});

  void _onTextChanged(String text) {
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(text));
  }

  void _flush(String text) {
    _timer?.cancel();
    widget.onChanged(text);
  }

  void _clear() {
    _controller.clear();
    _flush('');
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColors.strongCyan, width: 2),
    );

    return TextField(
      controller: _controller,
      onChanged: _onTextChanged,
      onSubmitted: _flush,
      textInputAction: TextInputAction.search,
      style: appText(size: widget.fontSize),
      cursorColor: AppColors.darkTeal,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: appText(size: widget.fontSize, color: AppColors.muted),
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: AppColors.darkTeal,
        ),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpiar búsqueda',
                onPressed: _clear,
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.darkTeal,
              ),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
