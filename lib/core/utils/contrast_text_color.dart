import 'package:flutter/material.dart';

/// Returns white or black text color for WCAG AA contrast (>= 4.5:1).
Color contrastTextColor(Color background) {
  final luminance = background.computeLuminance();
  // Relative luminance threshold for 4.5:1 contrast with white vs black.
  return luminance > 0.179 ? Colors.black : Colors.white;
}

/// Contrast ratio between two colors (for testing).
double contrastRatio(Color foreground, Color background) {
  final l1 = foreground.computeLuminance();
  final l2 = background.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}