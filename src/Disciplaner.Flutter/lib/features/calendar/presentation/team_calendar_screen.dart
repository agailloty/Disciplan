import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/core/widgets/priority_icon.dart'
    hide TicketType;
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/mobile_ticket_detail_sheet.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/split_inspector_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'calendar_providers.dart';

class TeamCalendarScreen extends ConsumerStatefulWidget {
  const TeamCalendarScreen({super.key});

  @override
  ConsumerState<TeamCalendarScreen> createState() => _TeamCalendarScreenState();
}

class _TeamCalendarScreenState extends ConsumerState<TeamCalendarScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  String _filter = 'all'; // 'all', 'sprints', 'tickets'

  TicketPriority _mapPriority(CardPriority p) {
    switch (p) {
      case CardPriority.low:
        return TicketPriority.low;
      case CardPriority.medium:
        return TicketPriority.medium;
      case CardPriority.high:
        return TicketPriority.high;
      case CardPriority.critical:
        return TicketPriority.urgent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenAsync = ref.watch(calendarTokenProvider);
    final myTasksAsync = ref.watch(myTasksProvider);
    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    final sprintsAsync = selectedProjectId != null
        ? ref.watch(projectSprintsProvider(selectedProjectId))
        : null;
    final selectedDetailId = ref.watch(selectedTicketDetailIdProvider);
    final isDesktop = MediaQuery.of(context).size.width >= NeoSpacing.mobileBreakpoint;
    final serverUrl = ref.watch(homelabServerUrlProvider);

    final mainContent = ListView(
      padding: const EdgeInsets.all(NeoSpacing.spaceLg),
      children: [
        // 1. Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calendrier d\'Équipe',
                  style: NeoTypography.headlineLg,
                ),
                const SizedBox(height: 4),
                Text(
                  'Jalons de sprint, échéances de tickets et synchronisation iCal',
                  style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: NeoSpacing.spaceLg),

        // 2. iCal Synchronization Card
        _buildICalCard(tokenAsync, serverUrl),
        const SizedBox(height: NeoSpacing.spaceLg),

        // 3. Month Navigation & Filter Pills
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month - 1,
                        1,
                      );
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth).toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: NeoColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month + 1,
                        1,
                      );
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                _buildFilterChip('all', 'Tout voir'),
                const SizedBox(width: NeoSpacing.spaceSm),
                _buildFilterChip('sprints', 'Sprints'),
                const SizedBox(width: NeoSpacing.spaceSm),
                _buildFilterChip('tickets', 'Tickets'),
              ],
            ),
          ],
        ),
        const SizedBox(height: NeoSpacing.spaceMd),

        // 4. Chronological Milestones
        _buildMilestonesTimeline(
          context,
          myTasksAsync.asData?.value ?? [],
          sprintsAsync?.asData?.value ?? [],
          isDesktop,
        ),
      ],
    );

    return Scaffold(
      backgroundColor: NeoColors.surfaceContainerLowest,
      body: Row(
        children: [
          Expanded(child: mainContent),
          if (selectedDetailId != null && isDesktop)
            SplitInspectorPanel(
              ticketId: selectedDetailId,
              onClose: () =>
                  ref.read(selectedTicketDetailIdProvider.notifier).clear(),
            ),
        ],
      ),
    );
  }

  Widget _buildICalCard(AsyncValue tokenAsync, String serverUrl) {
    return Container(
      padding: const EdgeInsets.all(NeoSpacing.spaceMd),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sync, color: NeoColors.secondary, size: 20),
              const SizedBox(width: NeoSpacing.spaceSm),
              Text(
                'Synchronisation iCal / Agenda externe',
                style: NeoTypography.headlineSm.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: NeoColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Apple • Google • Outlook',
                  style: NeoTypography.labelSm.copyWith(fontSize: 10, color: NeoColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: NeoSpacing.spaceSm),
          tokenAsync.when(
            data: (tokenDto) {
              if (tokenDto == null) {
                return Row(
                  children: [
                    Text(
                      'Aucun flux actif. Générez votre jeton privé pour synchroniser votre calendrier.',
                      style: NeoTypography.bodySm.copyWith(color: NeoColors.onSurfaceVariant),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => ref.read(calendarTokenProvider.notifier).regenerate(),
                      icon: const Icon(Icons.key, size: 16),
                      label: const Text('Générer le jeton'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NeoColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                );
              }

              final feedUrl = '$serverUrl/ical/${tokenDto.token}';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: NeoColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: NeoColors.borderWhisper),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 16, color: NeoColors.muted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feedUrl,
                            style: GoogleFonts.jetBrainsMono(fontSize: 12, color: NeoColors.primary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          tooltip: 'Copier l\'URL iCal',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: feedUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('URL du flux iCal copiée'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: NeoSpacing.spaceXs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Créé le ${DateFormat('dd/MM/yyyy').format(tokenDto.createdAt)}',
                        style: NeoTypography.labelSm.copyWith(color: NeoColors.muted),
                      ),
                      TextButton.icon(
                        onPressed: () => ref.read(calendarTokenProvider.notifier).regenerate(),
                        icon: const Icon(Icons.refresh, size: 14),
                        label: const Text('Régénérer le jeton'),
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (err, _) => Text('Erreur token: $err', style: NeoTypography.bodySm),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _filter == key;
    return ChoiceChip(
      label: Text(label),
      labelStyle: NeoTypography.labelSm.copyWith(
        color: isSelected ? Colors.white : NeoColors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      selected: isSelected,
      selectedColor: NeoColors.primary,
      backgroundColor: NeoColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      side: const BorderSide(color: NeoColors.borderWhisper),
      onSelected: (_) => setState(() => _filter = key),
    );
  }

  Widget _buildMilestonesTimeline(
    BuildContext context,
    List<TicketDto> tasks,
    List<dynamic> sprints,
    bool isDesktop,
  ) {
    final items = <Widget>[];

    // Sprints
    if (_filter == 'all' || _filter == 'sprints') {
      for (final s in sprints) {
        items.add(
          Container(
            margin: const EdgeInsets.only(bottom: NeoSpacing.spaceSm),
            padding: const EdgeInsets.all(NeoSpacing.spaceMd),
            decoration: BoxDecoration(
              color: NeoColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NeoColors.borderWhisper),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: NeoColors.secondaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.timelapse, color: NeoColors.secondary, size: 20),
                ),
                const SizedBox(width: NeoSpacing.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: NeoTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        s.goal ?? 'Jalon de cycle',
                        style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    s.status.name.toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // Tickets with dueDate
    if (_filter == 'all' || _filter == 'tickets') {
      final datedTickets = tasks.where((t) => t.dueDate != null).toList();
      for (final t in datedTickets) {
        items.add(
          InkWell(
            onTap: () {
              if (isDesktop) {
                ref.read(selectedTicketDetailIdProvider.notifier).select(t.id);
              } else {
                MobileTicketDetailSheet.show(context, t.id);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: NeoSpacing.spaceSm),
              padding: const EdgeInsets.all(NeoSpacing.spaceMd),
              decoration: BoxDecoration(
                color: NeoColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NeoColors.borderWhisper),
              ),
              child: Row(
                children: [
                  PriorityIcon(priority: _mapPriority(t.priority), size: 16),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  Text(
                    t.ticketRef,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.muted,
                    ),
                  ),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  Expanded(
                    child: Text(
                      t.title,
                      style: NeoTypography.bodyMd.copyWith(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (t.assigneeName != null) ...[
                    UserAvatar(name: t.assigneeName!, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: NeoColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: NeoColors.muted),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM').format(t.dueDate!),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: NeoColors.primary,
                          ),
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

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(NeoSpacing.spaceXl),
        alignment: Alignment.center,
        child: Text(
          'Aucun jalon ou ticket daté pour ce filtre.',
          style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
        ),
      );
    }

    return Column(children: items);
  }
}
