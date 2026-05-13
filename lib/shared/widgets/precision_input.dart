import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_constants.dart';
import 'precision_card.dart';

/// Finarcast Standart "Animated Precision" Giriş Alanı.
/// Odaklandığında (focus) hafifçe büyüyen, kenarlıkları parlayan ve premium hissiyat veren input.
class PrecisionInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final String? suffixText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final double scalingFactor;
  final Widget? suffix;
  final VoidCallback? onSubmitted;

  const PrecisionInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.suffixText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.autofocus = false,
    this.scalingFactor = 1.0,
    this.suffix,
    this.onSubmitted,
    this.obscureText = false,
    this.errorText,
    this.textAlign = TextAlign.start,
    this.showBackground = true,
    this.fontSize,
  });

  final bool obscureText;
  final String? errorText;
  final TextAlign textAlign;
  final bool showBackground;
  final double? fontSize;

  @override
  State<PrecisionInput> createState() => _PrecisionInputState();
}

class _PrecisionInputState extends State<PrecisionInput> with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.getPrimary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.showBackground 
            ? PrecisionCard(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2 * widget.scalingFactor),
                child: _buildTextField(activeColor, isDark),
              )
            : _buildTextField(activeColor, isDark),
          // Hata Mesajı Bölümü - Daha şık ve animasyonlu
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: widget.errorText != null
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 250),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, -5 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        widget.errorText!,
                        style: TextStyle(
                          color: Colors.redAccent.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(Color activeColor, bool isDark) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      obscureText: widget.obscureText,
      textAlign: widget.textAlign,
      cursorColor: activeColor,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      style: TextStyle(
        fontWeight: FontWeight.w900, 
        fontSize: widget.fontSize ?? (17 * widget.scalingFactor),
        color: AppColors.getTextPrimary(context),
        letterSpacing: widget.textAlign == TextAlign.center ? -1.0 : null,
      ),
      decoration: InputDecoration(
        icon: widget.textAlign == TextAlign.center 
          ? null 
          : AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(left: _isFocused ? 4 : 0),
              curve: Curves.easeOutBack,
              child: Icon(
                widget.icon, 
                color: activeColor.withValues(alpha: _isFocused ? 0.9 : 0.4), 
                size: 22 * widget.scalingFactor
              ),
            ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w500, 
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2), 
          fontSize: (widget.fontSize != null ? widget.fontSize! * 0.8 : 15 * widget.scalingFactor)
        ),
        prefixText: widget.textAlign == TextAlign.center ? widget.suffixText : null, // Center ise prefix olarak kullanabiliyoruz
        prefixStyle: TextStyle(
          fontWeight: FontWeight.w900, 
          color: activeColor.withValues(alpha: 0.4), 
          fontSize: (widget.fontSize != null ? widget.fontSize! * 0.8 : 15 * widget.scalingFactor)
        ),
        suffixText: widget.textAlign == TextAlign.center ? null : widget.suffixText,
        suffixStyle: TextStyle(
          fontWeight: FontWeight.w900, 
          color: activeColor.withValues(alpha: _isFocused ? 0.9 : 0.4), 
          fontSize: 15 * widget.scalingFactor
        ),
        suffixIcon: widget.suffix,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8 * widget.scalingFactor),
      ),
    );
  }
}
