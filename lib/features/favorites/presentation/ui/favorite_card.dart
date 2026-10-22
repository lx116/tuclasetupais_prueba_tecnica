import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/contacts/domain/entities/contact.dart';
import '../../../../core/favorites/presentation/favorite_button.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/initials.dart';

/// A favorite contact: opens its detail on tap, with a star to remove it.
class FavoriteCard extends StatelessWidget {
  const FavoriteCard({super.key, required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context.go(AppRoutes.contactDetail(contact.id)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 4, 14),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.tint,
                      ),
                      child: Text(
                        initialsOf(contact.name),
                        style: appText(
                          size: 16,
                          weight: 800,
                          color: AppColors.darkTeal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            contact.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: appText(size: 16, weight: 700),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.tint,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              contact.department,
                              style: appText(
                                size: 12,
                                weight: 700,
                                color: AppColors.darkTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FavoriteButton(contactId: contact.id),
          ),
        ],
      ),
    );
  }
}
