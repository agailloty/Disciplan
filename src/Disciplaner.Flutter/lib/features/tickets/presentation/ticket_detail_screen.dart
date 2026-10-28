import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'ticket_providers.dart';
import 'widgets/mobile_ticket_detail_sheet.dart';
import 'widgets/split_inspector_panel.dart';

class TicketDetailScreen extends ConsumerWidget {
  final String ticketRef;

  const TicketDetailScreen({
    super.key,
    required this.ticketRef,
  });

  // La page de détail est souvent la seule page du Navigator (deep link ou
  // context.go) : un pop ne ferait que vider l'écran. On revient alors à
  // l'accueil.
  void _closeTicketPage(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/dashboard');
    }
  }

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
              onClose: () => _closeTicketPage(context),
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
                onPressed: () => _closeTicketPage(context),
                child: Text(l10n.back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
