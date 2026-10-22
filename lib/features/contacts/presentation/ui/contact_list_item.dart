import 'package:flutter/material.dart';

import '../../../../core/contacts/domain/entities/contact.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/initials.dart';

/// Row for a single [Contact].
///
/// [card] is the mobile look (rounded card, department, chevron); otherwise it
/// is the flat row of the wide column (email, highlighted when [selected]).
class ContactListItem extends StatelessWidget {
  const ContactListItem({
    super.key,
    required this.contact,
    this.onTap,
    this.selected = false,
    this.card = false,
  });

  final Contact contact;
  final VoidCallback? onTap;
  final bool selected;
  final bool card;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? AppColors.surface : AppColors.tint,
          ),
          child: Text(
            initialsOf(contact.name),
            style: appText(size: 14, weight: 800, color: AppColors.darkTeal),
          ),
        ),
        SizedBox(width: card ? 12 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contact.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: appText(size: 15, weight: 700),
              ),
              const SizedBox(height: 2),
              Text(
                card ? contact.department : contact.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: appText(size: 13, color: AppColors.muted),
              ),
            ],
          ),
        ),
        if (!contact.active) ...[
          const SizedBox(width: 8),
          Text(
            'Inactivo',
            style: appText(size: 12, weight: 600, color: AppColors.muted),
          ),
        ],
        if (card) ...[
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.darkTeal),
        ],
      ],
    );

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: card
            ? AppColors.surface
            : (selected ? AppColors.tint : AppColors.surface),
        shape: card
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              )
            : const Border(bottom: BorderSide(color: AppColors.divider)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: card ? 14 : 16,
              vertical: 12,
            ),
            decoration: !card && selected
                ? const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppColors.strongCyan, width: 4),
                    ),
                  )
                : null,
            child: content,
          ),
        ),
      ),
    );
  }
}
