import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Home ekranının scroll durumunu paylaşmak için provider.
final homeScrollProvider = Provider<ScrollController>((ref) {
  final controller = ScrollController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Scroll yönünü takip eden provider (true = Yukarı/Duruyor, false = Aşağı).
final isScrollingDownProvider = StateProvider<bool>((ref) => false);
