import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/favorites/presentation/favorites_cubit.dart';
import '../../../../core/favorites/presentation/favorites_state.dart';
import '../../../../core/layout/breakpoints.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/back_to_contacts_button.dart';
import '../../../../core/widgets/brand_header.dart';
import '../../../../core/widgets/header_nav.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_message.dart';
import '../cubit/favorite_contacts_cubit.dart';
import '../cubit/favorite_contacts_provider.dart';
import '../cubit/favorite_contacts_state.dart';
import 'favorite_card.dart';

/// `/favorites`: the contacts marked with a star.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = isWideWidth(MediaQuery.sizeOf(context).width);

    return Scaffold(
      body: FavoriteContactsProvider(
        child: Column(
          children: [
            BrandHeader(
              compact: !wide,
              trailing: HeaderNav(
                current: HeaderSection.favorites,
                compact: !wide,
              ),
            ),
            const Expanded(child: _FavoritesBody()),
          ],
        ),
      ),
    );
  }
}

class _FavoritesBody extends StatelessWidget {
  const _FavoritesBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favorites) =>
          _ContactsLoader(ids: favorites.ids, loaded: favorites.loaded),
    );
  }
}

/// Asks for the contacts of the favorites, again whenever they change.
class _ContactsLoader extends StatefulWidget {
  const _ContactsLoader({required this.ids, required this.loaded});

  final Set<int> ids;
  final bool loaded;

  @override
  State<_ContactsLoader> createState() => _ContactsLoaderState();
}

class _ContactsLoaderState extends State<_ContactsLoader> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_ContactsLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loaded != oldWidget.loaded || widget.ids != oldWidget.ids) {
      _load();
    }
  }

  // Until the stored favorites are read there is nothing to ask for.
  void _load() {
    if (widget.loaded) {
      context.read<FavoriteContactsCubit>().load(widget.ids);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = isWideWidth(MediaQuery.sizeOf(context).width);
    final padding = wide
        ? const EdgeInsets.fromLTRB(24, 32, 24, 48)
        : const EdgeInsets.fromLTRB(16, 20, 16, 24);

    return BlocBuilder<FavoriteContactsCubit, FavoriteContactsState>(
      builder: (context, state) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: padding,
                sliver: SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(child: _Title(wide: wide)),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ..._content(context, state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, FavoriteContactsState state) {
    return switch (state) {
      FavoriteContactsLoading() => const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.darkTeal),
            ),
          ),
        ),
      ],
      FavoriteContactsEmpty() => [
        _message(
          StateMessage(
            icon: Icons.star_border,
            title: 'Todavía no tienes favoritos',
            message: 'Toca la estrella de un contacto para guardarlo aquí.',
            action: PrimaryButton(
              label: 'Ver contactos',
              onPressed: () => context.go(AppRoutes.contactsLocation()),
            ),
          ),
        ),
      ],
      FavoriteContactsError(:final message) => [
        _message(
          StateMessage(
            isError: true,
            icon: Icons.error_outline,
            title: 'No pudimos cargar los favoritos',
            message: message,
            action: const BackToContactsButton(),
          ),
        ),
      ],
      FavoriteContactsData(:final contacts) => [
        SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 420,
            mainAxisExtent: 84,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: contacts.length,
          itemBuilder: (context, index) =>
              FavoriteCard(contact: contacts[index]),
        ),
      ],
    };
  }

  Widget _message(Widget child) => SliverToBoxAdapter(
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: child,
      ),
    ),
  );
}

class _Title extends StatelessWidget {
  const _Title({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favoritos',
          style: appText(
            size: wide ? 34 : 26,
            weight: 800,
            color: AppColors.darkTeal,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tus contactos marcados con estrella. Se guardan en este dispositivo.',
          style: appText(size: 15, color: AppColors.muted),
        ),
      ],
    );
  }
}
