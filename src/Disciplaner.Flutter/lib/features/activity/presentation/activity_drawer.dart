import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/errors/app_failure.dart';
import 'package:disciplaner_flutter/core/l10n/failure_l10n.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'activity_providers.dart';

class ActivityDrawer extends ConsumerWidget {
  const ActivityDrawer({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.ticketHistory,
      barrierColor: Colors.black38,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: const ActivityDrawer(),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider);
    final l10n = context.l10n;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 380,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: NeoColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Color(0x1F1A1917),
              blurRadius: 30,
              offset: Offset(-8, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: NeoColors.borderWhisper, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_outlined, size: 20, color: NeoColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.homeActivity,
                          style: NeoTypography.headlineSm.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: activityAsync.when(
                data: (activities) {
                  if (activities.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.homeNoActivity,
                        style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                    itemCount: activities.length,
                    separatorBuilder: (_, _) => const Divider(height: 16, color: NeoColors.surfaceContainerHigh),
                    itemBuilder: (context, index) {
                      final item = activities[index];

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: NeoColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              _mapIcon(item.kind),
                              size: 16,
                              color: NeoColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.summary,
                                  style: NeoTypography.bodySm.copyWith(color: NeoColors.primary),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (item.ticketRef != null) ...[
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          context.go('/tickets/${item.ticketRef}');
                                        },
                                        child: Text(
                                          item.ticketRef!,
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: NeoColors.secondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      DateFormat('dd/MM HH:mm').format(item.occurredAt),
                                      style: NeoTypography.labelSm.copyWith(color: NeoColors.muted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (err, _) {
                  final message = err is AppFailure
                      ? localizedFailureMessage(l10n, err)
                      : l10n.shellActivityError(err.toString());
                  return Center(child: Text(message, style: NeoTypography.bodySm));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _mapIcon(String kind) {
    final lower = kind.toLowerCase();
    if (lower.contains('comment')) return Icons.chat_bubble_outline;
    if (lower.contains('status')) return Icons.sync_alt;
    if (lower.contains('attach')) return Icons.attach_file;
    if (lower.contains('sprint')) return Icons.timelapse;
    return Icons.notifications_none;
  }
}
