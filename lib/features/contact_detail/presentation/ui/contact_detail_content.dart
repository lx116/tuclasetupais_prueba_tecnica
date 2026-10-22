import 'package:flutter/material.dart';

import '../../../../core/contacts/domain/entities/contact.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/initials.dart';

/// Presentational body of the detail. [wide] is the side-by-side look
/// (banner card, label and value on one line); otherwise the mobile look.
class ContactDetailContent extends StatelessWidget {
  const ContactDetailContent({
    super.key,
    required this.contact,
    required this.wide,
  });

  final Contact contact;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return wide ? _Wide(contact: contact) : _Mobile(contact: contact);
  }
}

class _Wide extends StatelessWidget {
  const _Wide({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Card(
                padding: EdgeInsets.zero,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(height: 88, color: AppColors.darkTeal),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(144, 12, 28, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.name,
                                style: appText(
                                  size: 24,
                                  weight: 800,
                                  color: AppColors.darkTeal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${contact.role} · ${contact.department}',
                                style: appText(
                                  size: 14,
                                  color: AppColors.muted,
                                ),
                              ),
                              if (!contact.active) ...[
                                const SizedBox(height: 8),
                                const _Pill(label: 'Inactivo'),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 28,
                      top: 44,
                      child: _Avatar(name: contact.name, size: 96, border: 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _Card(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    _WideRow(label: 'Correo', value: contact.email),
                    _WideRow(label: 'Teléfono', value: contact.phone),
                    _WideRow(
                      label: 'Departamento',
                      value: contact.department,
                      last: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(height: 72, color: AppColors.darkTeal),
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            _Card(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 22),
              child: Column(
                children: [
                  _Avatar(name: contact.name, size: 88, border: 0),
                  const SizedBox(height: 12),
                  Text(
                    contact.name,
                    textAlign: TextAlign.center,
                    style: appText(
                      size: 22,
                      weight: 800,
                      color: AppColors.darkTeal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contact.role,
                    style: appText(size: 14, color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _Pill(label: contact.department),
                      if (!contact.active) const _Pill(label: 'Inactivo'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Card(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  _StackedRow(label: 'Correo', value: contact.email),
                  _StackedRow(label: 'Teléfono', value: contact.phone),
                  _StackedRow(
                    label: 'Departamento',
                    value: contact.department,
                    last: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.size, required this.border});

  final String name;
  final double size;
  final double border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.tint,
        border: border > 0
            ? Border.all(color: AppColors.surface, width: border)
            : null,
      ),
      child: Text(
        initialsOf(name),
        style: appText(
          size: size > 90 ? 30 : 28,
          weight: 800,
          color: AppColors.darkTeal,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: appText(size: 12, weight: 700, color: AppColors.darkTeal),
      ),
    );
  }
}

class _WideRow extends StatelessWidget {
  const _WideRow({required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: appText(size: 14, color: AppColors.muted)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: appText(size: 15, weight: 600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedRow extends StatelessWidget {
  const _StackedRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: appText(size: 12, color: AppColors.muted)),
          const SizedBox(height: 2),
          Text(value, style: appText(size: 15, weight: 600)),
        ],
      ),
    );
  }
}
