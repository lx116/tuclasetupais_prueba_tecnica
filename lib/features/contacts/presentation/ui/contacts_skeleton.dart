import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Placeholder rows shown while the contacts load.
class ContactsSkeleton extends StatelessWidget {
  const ContactsSkeleton({super.key, this.rows = 6});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Cargando contactos',
      container: true,
      child: ExcludeSemantics(
        child: Column(
          children: [for (var i = 0; i < rows; i++) const _SkeletonRow()],
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          const _Block(
            width: 46,
            height: 46,
            color: AppColors.tint,
            circle: true,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.45,
                  child: const _Block(height: 12, color: AppColors.skeleton),
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: const _Block(
                    height: 10,
                    color: AppColors.skeletonSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    this.width,
    required this.height,
    required this.color,
    this.circle = false,
  });

  final double? width;
  final double height;
  final Color color;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(6),
      ),
    );
  }
}
