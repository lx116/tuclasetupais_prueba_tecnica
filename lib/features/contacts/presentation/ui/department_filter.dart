import 'package:flutter/material.dart';

import '../../../../core/contacts/domain/entities/contact_catalog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/text_folding.dart';

/// Department chips: "Todos" plus one per catalog department.
///
/// [selected] and [onChanged] use the URL form of the department
/// (`ingenieria`); the empty string is "Todos".
class DepartmentFilter extends StatelessWidget {
  const DepartmentFilter({
    super.key,
    required this.selected,
    required this.onChanged,
    this.height = 34,
  });

  final String selected;
  final ValueChanged<String> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final current = foldText(selected.trim());
    final options = <({String label, String value})>[
      (label: 'Todos', value: ''),
      for (final department in ContactDepartments.all)
        (label: department, value: foldText(department)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options) ...[
            _Chip(
              key: ValueKey(
                'department-chip-${option.value.isEmpty ? 'all' : option.value}',
              ),
              label: option.label,
              selected: option.value == current,
              height: height,
              onTap: () => onChanged(option.value),
            ),
            if (option != options.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.label,
    required this.selected,
    required this.height,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.strongCyan : AppColors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AppColors.strongCyan : AppColors.line,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              label,
              style: appText(size: 13, weight: selected ? 700 : 600),
            ),
          ),
        ),
      ),
    );
  }
}
