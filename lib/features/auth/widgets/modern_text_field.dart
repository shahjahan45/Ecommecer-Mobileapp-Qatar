import 'package:flutter/material.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';

class ModernTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    required this.textInputAction,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant ModernTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChange);
      widget.focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focused != widget.focusNode.hasFocus) {
      setState(() => _focused = widget.focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standardCurve,
          decoration: BoxDecoration(
            color: _focused
                ? Colors.white
                : AppColors.surfaceMuted.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: _focused ? AppColors.primary : AppColors.border,
              width: _focused ? 1.4 : 1,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : const [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: widget.obscureText,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted,
            autofillHints: widget.autofillHints,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 6, right: 2),
                child: Icon(
                  widget.icon,
                  color: _focused ? AppColors.primary : AppColors.textSecondary,
                  size: 21,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              errorStyle: const TextStyle(
                color: Color(0xFFB44E59),
                fontSize: 11.5,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
