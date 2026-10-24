import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ticket_providers.dart';
import 'widgets/mobile_ticket_detail_sheet.dart';
import 'widgets/split_inspector_panel.dart';

class TicketDetailScreen extends ConsumerWidget {
  final String ticketRef;

  const TicketDetailScreen({
    super.key,
    required this.ticketRef,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ticketAsync = ref.watch(ticketByRefProvider(ticketRef));

    return Scaffold(
      backgroundColor: NeoColors.surface,
      body: ticketAsync.when(
        data: (ticket) {
          final isDesktop = MediaQuery.of(context).size.width >= NeoSpacing.mobileBreakpoint;
          if (isDesktop) {
            // Page desktop pleine largeur : le panneau passe en mode
            // autonome (deux colonnes : contenu + propriétés).
            return SplitInspectorPanel(
              ticketId: ticket.id,
              standalone: true,
              onClose: () => Navigator.of(context).maybePop(),
            );
          } else {
            return MobileTicketDetailSheet(ticketId: ticket.id);
          }
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: NeoColors.primary),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: NeoColors.error),
              const SizedBox(height: NeoSpacing.spaceMd),
              Text(l10n.ticketsNotFoundRef(ticketRef)),
              const SizedBox(height: NeoSpacing.spaceMd),
              ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(l10n.back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
