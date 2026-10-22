import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import 'favorites_cubit.dart';

/// Star that adds or removes a contact from the favorites. It needs a
/// [FavoritesCubit] above it (the router provides one).
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.contactId,
    this.color = AppColors.darkTeal,
    this.size = 22,
  });

  final int contactId;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final favorite = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.state.isFavorite(contactId),
    );

    return IconButton(
      tooltip: favorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
      onPressed: () => context.read<FavoritesCubit>().toggle(contactId),
      icon: Icon(
        favorite ? Icons.star : Icons.star_border,
        size: size,
        color: color,
      ),
    );
  }
}

/// Wide version of the star for the detail: a button that says what it does.
class FavoritePillButton extends StatelessWidget {
  const FavoritePillButton({super.key, required this.contactId});

  final int contactId;

  @override
  Widget build(BuildContext context) {
    final favorite = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.state.isFavorite(contactId),
    );

    return Material(
      color: favorite ? AppColors.strongCyan : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: favorite
            ? BorderSide.none
            : const BorderSide(color: AppColors.darkTeal, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        toggled: favorite,
        child: InkWell(
          onTap: () => context.read<FavoritesCubit>().toggle(contactId),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  favorite ? Icons.star : Icons.star_border,
                  size: 18,
                  color: favorite ? AppColors.ink : AppColors.darkTeal,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    favorite ? 'En favoritos' : 'Agregar a favoritos',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appText(
                      size: 14,
                      weight: 700,
                      color: favorite ? AppColors.ink : AppColors.darkTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
