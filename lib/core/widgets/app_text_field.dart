import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.multiline = false,
    this.maxLines,
    this.minLines,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final bool multiline;
  final int? maxLines;
  final int? minLines;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  static const double _circleSize = 56;
  static const double _fieldHeight = 48;
  static const double _circleOverlap = 20;
  static const double _shadowBlur = 8;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (widget.multiline) _buildMultiline(context) else _buildDefault(context),
      ],
    );
  }

  Widget _buildDefault(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: _shadowBlur),
      child: SizedBox(
        height: _circleSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: _circleSize - _circleOverlap),
              child: Center(
                child: SizedBox(
                  height: _fieldHeight,
                  child: _textField(
                    context,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: _circleSize,
                height: _circleSize,
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurfaceVariant,
                        size: 24,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiline(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: _shadowBlur),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: _circleSize - _circleOverlap),
            child: _textField(
              context,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: _circleSize,
              height: _circleSize,
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant,
                      size: 24,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(
    BuildContext context, {
    required BorderRadius borderRadius,
    required EdgeInsets contentPadding,
  }) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      keyboardType: widget.multiline ? TextInputType.multiline : widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      maxLines: widget.multiline ? (widget.maxLines ?? 8) : 1,
      minLines: widget.multiline ? (widget.minLines ?? 3) : null,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      onChanged: widget.onChanged,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        prefixIcon: null,
        suffixIcon: widget.suffixIcon,
        filled: true,
        fillColor: context.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        contentPadding: contentPadding,
      ),
    );
  }
}
