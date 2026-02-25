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
    this.isPassword = false,
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
  final bool isPassword;
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
  bool _obscureText = true;

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

  // Proportions relative to bodyMedium fontSize:
  // On a standard phone (fontSize ≈ 14): circle=56, field=48, overlap=20, etc.
  static const double _circleFactor = 4.0;     // 14 * 4 = 56
  static const double _fieldFactor = 3.43;     // 14 * 3.43 ≈ 48
  static const double _overlapFactor = 1.43;   // 14 * 1.43 ≈ 20
  static const double _shadowFactor = 0.57;    // 14 * 0.57 ≈ 8
  static const double _iconFactor = 1.71;      // 14 * 1.71 ≈ 24
  static const double _radiusFactor = 1.71;    // 14 * 1.71 ≈ 24

  @override
  Widget build(BuildContext context) {
    final fontSize = context.textTheme.bodyMedium!.fontSize!;
    final circleSize = fontSize * _circleFactor;
    final fieldHeight = fontSize * _fieldFactor;
    final circleOverlap = fontSize * _overlapFactor;
    final shadowBlur = fontSize * _shadowFactor;
    final iconSize = fontSize * _iconFactor;
    final borderRadius = fontSize * _radiusFactor;
    final hPadding = fontSize * 1.71;  // 24
    final vPadding = fontSize * 0.86;  // 12
    final trailingPadding = fontSize * 1.14;  // 16
    final labelBottom = fontSize * 0.57;  // 8

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: EdgeInsets.only(bottom: labelBottom),
            child: Text(
              widget.label!,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (widget.multiline)
          _buildMultiline(
            context,
            circleSize: circleSize,
            circleOverlap: circleOverlap,
            shadowBlur: shadowBlur,
            iconSize: iconSize,
            borderRadius: borderRadius,
            hPadding: hPadding,
            vPadding: vPadding,
            trailingPadding: trailingPadding,
          )
        else
          _buildDefault(
            context,
            circleSize: circleSize,
            fieldHeight: fieldHeight,
            circleOverlap: circleOverlap,
            shadowBlur: shadowBlur,
            iconSize: iconSize,
            borderRadius: borderRadius,
            hPadding: hPadding,
            vPadding: vPadding,
            trailingPadding: trailingPadding,
          ),
      ],
    );
  }

  Widget _buildDefault(
    BuildContext context, {
    required double circleSize,
    required double fieldHeight,
    required double circleOverlap,
    required double shadowBlur,
    required double iconSize,
    required double borderRadius,
    required double hPadding,
    required double vPadding,
    required double trailingPadding,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: shadowBlur),
      child: SizedBox(
        height: circleSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(left: circleSize - circleOverlap),
              child: Center(
                child: SizedBox(
                  height: fieldHeight,
                  child: _textField(
                    context,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(borderRadius),
                      bottomRight: Radius.circular(borderRadius),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(
                      hPadding, vPadding, trailingPadding, vPadding,
                    ),
                    iconSize: iconSize,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _circleContent(
                context,
                circleSize: circleSize,
                shadowBlur: shadowBlur,
                iconSize: iconSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiline(
    BuildContext context, {
    required double circleSize,
    required double circleOverlap,
    required double shadowBlur,
    required double iconSize,
    required double borderRadius,
    required double hPadding,
    required double vPadding,
    required double trailingPadding,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: shadowBlur),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(left: circleSize - circleOverlap),
            child: _textField(
              context,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
                bottomLeft: Radius.circular(borderRadius),
              ),
              contentPadding: EdgeInsets.fromLTRB(
                hPadding, vPadding, trailingPadding, vPadding,
              ),
              iconSize: iconSize,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: _circleContent(
              context,
              circleSize: circleSize,
              shadowBlur: shadowBlur,
              iconSize: iconSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleContent(
    BuildContext context, {
    required double circleSize,
    required double shadowBlur,
    required double iconSize,
  }) {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: shadowBlur,
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
              size: iconSize,
            )
          : null,
    );
  }

  Widget _textField(
    BuildContext context, {
    required BorderRadius borderRadius,
    required EdgeInsets contentPadding,
    required double iconSize,
  }) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.isPassword && _obscureText,
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
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: context.colorScheme.onSurfaceVariant,
                  size: iconSize,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : widget.suffixIcon,
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
