import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../favorites/presentation/favorites_cubit.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

enum HeaderSection { contacts, favorites }

/// Navigation between the contacts and the favorites, shown in the header.
/// Wide: two pills, the favorites one with a count badge. [compact]: a single
/// icon that goes to the other section. It needs a [FavoritesCubit] above it.
class HeaderNav extends StatelessWidget {
  const HeaderNav({super.key, required this.current, this.compact = false});

  final HeaderSection current;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final count = context.select<FavoritesCubit, int>(
      (cubit) => cubit.state.count,
    );
    return compact ? _compact(context, count) : _wide(context, count);
  }

  Widget _wide(BuildContext context, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Pill(
          label: 'Contactos',
          active: current == HeaderSection.contacts,
          onTap: () => context.go(AppRoutes.contactsLocation()),
        ),
        const SizedBox(width: 8),
        _Pill(
          label: 'Favoritos',
          active: current == HeaderSection.favorites,
          badge: count,
          onTap: () => context.go(AppRoutes.favorites),
        ),
      ],
    );
  }

  Widget _compact(BuildContext context, int count) {
    if (current == HeaderSection.favorites) {
      return IconButton(
        tooltip: 'Contactos',
        onPressed: () => context.go(AppRoutes.contactsLocation()),
        icon: const Icon(Icons.people_outline, color: AppColors.mintCream),
      );
    }
    return IconButton(
      tooltip: 'Favoritos',
      onPressed: () => context.go(AppRoutes.favorites),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: AppColors.strongCyan,
        textColor: AppColors.ink,
        child: const Icon(Icons.star_border, color: AppColors.mintCream),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.active,
    required this.onTap,
    this.badge = 0,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.strongCyan : Colors.transparent,
      shape: StadiumBorder(
        side: active
            ? BorderSide.none
            : const BorderSide(color: Color(0xFF3F7A82)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        selected: active,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: appText(
                    size: 14,
                    weight: 700,
                    color: active ? AppColors.ink : AppColors.mintCream,
                  ),
                ),
                if (badge > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$badge',
                      style: appText(
                        size: 12,
                        weight: 700,
                        color: AppColors.mintCream,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
