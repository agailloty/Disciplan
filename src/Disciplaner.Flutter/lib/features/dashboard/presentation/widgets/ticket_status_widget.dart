import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';

/// Widget compact pour afficher rapidement les tickets en cours et a faire.
class TicketStatusWidget extends ConsumerWidget {
  final bool showInProgress;
  final bool showBacklog;
  final int maxItems;
  final VoidCallback? onTap;

  const TicketStatusWidget({
    super.key,
    this.showInProgress = true,
    this.showBacklog = true,
    this.maxItems = 5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final myTicketsAsync = ref.watch(myTasksProvider);

    return Container(
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        borderRadius: NeoSpacing.roundedLg,
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: myTicketsAsync.when(
        loading: () => _buildLoading(),
        error: (error, stack) => _buildError(error),
        data: (tickets) => _buildContent(context, tickets, l10n),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(Object error) {
    return Center(child: Text('Error loading tickets'));
  }

  Widget _buildContent(BuildContext context, List<TicketDto> tickets, AppLocalizations l10n) {
    final inProgress = showInProgress
        ? tickets.where((t) => t.status.category == StatusCategory.inProgress).toList()
        : [];
    final backlog = showBacklog
        ? tickets.where((t) => t.status.category == StatusCategory.backlog).toList()
        : [];
    
    final allTickets = [...inProgress, ...backlog];
    final displayed = allTickets.take(maxItems).toList();
    final hasMore = allTickets.length > maxItems;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.myticketsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildBadge(inProgress.length, l10n.statuscategoryInProgress, NeoColors.statusAmber),
                  const SizedBox(width: 8),
                  _buildBadge(backlog.length, l10n.statuscategoryBacklog, NeoColors.statusBlue),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        if (displayed.isEmpty)
          const Padding(padding: EdgeInsets.all(16), child: Text('No tickets assigned'))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayed.length + (hasMore ? 1 : 0),
            itemBuilder: (ctx, idx) {
              if (idx == displayed.length) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('+${allTickets.length - maxItems} more'),
                );
              }
              return _buildTicketItem(displayed[idx]);
            },
          ),
      ],
    );
  }

  Widget _buildBadge(int count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count'),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildTicketItem(TicketDto ticket) {
    return ListTile(
      title: Text('${ticket.projectKey}-${ticket.ticketNumber}: ${ticket.title}'),
      subtitle: Text(ticket.priority.name),
    );
  }
}
