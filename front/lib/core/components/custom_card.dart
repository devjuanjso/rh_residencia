import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final double elevation;
  final Color? color;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.elevation = 4,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: _getBorderRadius(),
      ),
      child: Padding(
        padding: _getPadding(),
        child: child,
      ),
    );
  }

  BorderRadiusGeometry _getBorderRadius() {
    return borderRadius ?? BorderRadius.circular(16);
  }

  EdgeInsetsGeometry _getPadding() {
    return padding ?? const EdgeInsets.all(16);
  }
}