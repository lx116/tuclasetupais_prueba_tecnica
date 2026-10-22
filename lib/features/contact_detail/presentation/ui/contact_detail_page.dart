import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/router/current_location.dart';
import '../../../../core/router/not_found_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/back_to_contacts_button.dart';
import '../../../../core/widgets/state_message.dart';
import '../cubit/contact_detail_cubit.dart';
import '../cubit/contact_detail_provider.dart';
import '../cubit/contact_detail_state.dart';
import 'contact_detail_content.dart';

class ContactDetailPage extends StatelessWidget {
  const ContactDetailPage({super.key, required this.contactId});

  final int contactId;

  @override
  Widget build(BuildContext context) {
    return ContactDetailProvider(
      contactId: contactId,
      child: BlocBuilder<ContactDetailCubit, ContactDetailState>(
        builder: (context, state) {
          final wide = isWideWidth(MediaQuery.sizeOf(context).width);
          final body = switch (state) {
            ContactDetailLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.darkTeal),
            ),
            ContactDetailNotFound() => const NotFoundPage(
              message: 'Contacto no encontrado',
            ),
            ContactDetailError(:final message) => StateMessage(
              isError: true,
              icon: Icons.error_outline,
              title: 'No pudimos cargar el contacto',
              message: message,
              action: const BackToContactsButton(),
            ),
            ContactDetailData(:final contact) => ContactDetailContent(
              contact: contact,
              wide: wide,
            ),
          };

          if (wide) return body;
          return Column(
            children: [
              const _MobileHeader(),
              Expanded(child: body),
            ],
          );
        },
      ),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkTeal,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Volver a contactos',
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(
                        AppRoutes.contactsLocation(
                          query: currentQueryOf(context),
                        ),
                      ),
                icon: const Icon(Icons.chevron_left, size: 28),
                color: AppColors.mintCream,
              ),
              Expanded(
                child: Text(
                  'Detalle',
                  textAlign: TextAlign.center,
                  style: appText(
                    size: 16,
                    weight: 700,
                    color: AppColors.mintCream,
                  ),
                ),
              ),
              // Keeps the title centered next to the back button.
              const SizedBox(width: 56),
            ],
          ),
        ),
      ),
    );
  }
}
