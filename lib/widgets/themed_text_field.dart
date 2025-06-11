import 'package:flutter/material.dart';

class ThemedTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final void Function()? onEditingComplete;
  final void Function(String)? onSubmitted;

  const ThemedTextField({
    Key? key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<ThemedTextField> createState() => _ThemedTextFieldState();
}

class _ThemedTextFieldState extends State<ThemedTextField> {
  // Add state to track password visibility
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    // Initialize based on if this is a password field
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleMedium?.color,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor, width: 1.5),
            borderRadius: BorderRadius.circular(10),
            color: theme.brightness == Brightness.dark 
                ? theme.cardColor 
                : Colors.white,
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            validator: widget.validator,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            focusNode: widget.focusNode,
            textInputAction: widget.textInputAction,
            onEditingComplete: widget.onEditingComplete,
            onFieldSubmitted: widget.onSubmitted,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 16,
            ),
            cursorColor: theme.primaryColor,
            decoration: InputDecoration(
              prefixIcon: Icon(
                widget.icon, 
                color: theme.primaryColor,
                size: 20,
              ),
              suffixIcon: widget.isPassword 
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              hintText: 'Enter your ${widget.label}',
              hintStyle: TextStyle(
                color: theme.hintColor,
              ),
              filled: false,
            ),
          ),
        ),
      ],
    );
  }
}