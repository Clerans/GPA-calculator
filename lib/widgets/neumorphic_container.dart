import 'package:flutter/material.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool isPressed;
  final Color? color;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 16.0,
    this.isPressed = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Base color for Neumorphism
    final Color baseColor = color ?? const Color(0xFFE0E5EC);
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? null // Inset effect would go here, but avoiding complex painting for now. Flattening for pressed.
            : [
                BoxShadow(
                  color: Colors.white,
                  offset: const Offset(-6, -6),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: const Color(0xFFA3B1C6),
                  offset: const Offset(6, 6),
                  blurRadius: 12,
                ),
              ],
        // If pressed, we simulate inset differently or just remove shadow?
        // For simplicity/performance in this iteration, "isPressed" removes elevation
        // or we could add a subtle inner border or color shift.
        border: isPressed 
          ? Border.all(color: Colors.white.withOpacity(0.5), width: 1)
          : null,
      ),
      child: child,
    );
  }
}
