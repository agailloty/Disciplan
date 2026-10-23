import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/neo_text_field.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/dense_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../sprint_providers.dart';

class CreateSprintModal extends ConsumerStatefulWidget {
  final String projectId;

  const CreateSprintModal({
    super.key,
    required this.projectId,
  });

  static Future<void> show(BuildContext context, {required String projectId}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (context) => CreateSprintModal(projectId: projectId),
    );
  }

  @override
  ConsumerState<CreateSprintModal> createState() => _CreateSprintModalState();
}

class _CreateSprintModalState extends ConsumerState<CreateSprintModal> {
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();

  final DateTime _startDate = DateTime.now();
  late DateTime _endDate;
  int _cadenceDays = 14;
  bool _startImmediately = false;
  bool _isLoading = false;
  String? _errorMessage;

  final Set<String> _selectedBacklogTicketIds = {};

  @override
  void initState() {
    super.initState();
    _endDate = _startDate.add(Duration(days: _cadenceDays));
    _nameController.text = 'Sprint ${DateTime.now().month} — Optimisations & Livrables';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _setCadence(int days) {
    setState(() {
      _cadenceDays = days;
      _endDate = _startDate.add(Duration(days: days));
    });
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Veuillez saisir un nom de sprint.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sprintRepo = ref.read(sprintRepositoryProvider);
      final ticketRepo = ref.read(ticketRepositoryProvider);

      // 1. Create Sprint
      final sprint = await sprintRepo.create(
        widget.projectId,
        CreateSprintRequest(
          name: name,
          goal: _goalController.text.trim().isEmpty
              ? null
              : _goalController.text.trim(),
        ),
      );

      // 2. Attach selected backlog tickets
      for (final ticketId in _selectedBacklogTicketIds) {
        await ticketRepo.moveToSprint(ticketId, sprint.id);
      }

      // 3. Start immediately if checked
      if (_startImmediately) {
        await sprintRepo.start(
          sprint.id,
          StartSprintRequest(
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
      }

      ref.invalidate(projectSprintsProvider(widget.projectId));
      ref.invalidate(projectBacklogProvider(widget.projectId));

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sprint créé avec succès !')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backlogAsync = ref.watch(projectBacklogProvider(widget.projectId));
    final dateFormatter = DateFormat('dd MMM yyyy', 'fr_FR');

    return Dialog(
      backgroundColor: NeoColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: NeoSpacing.roundedXl,
        side: const BorderSide(color: NeoColors.borderWhisper),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(NeoSpacing.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: NeoColors.kineticAmber.withValues(alpha: 0.15),
                          borderRadius: NeoSpacing.roundedMd,
                        ),
                        child: const Icon(
                          Icons.timelapse,
                          size: 20,
                          color: NeoColors.secondary,
                        ),
                      ),
                      const SizedBox(width: NeoSpacing.spaceSm),
                      Text('Créer et planifier un cycle', style: NeoTypography.headlineMd),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: NeoColors.muted,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: NeoSpacing.spaceMd),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(NeoSpacing.spaceSm),
                  decoration: BoxDecoration(
                    color: NeoColors.error.withValues(alpha: 0.1),
                    borderRadius: NeoSpacing.roundedSm,
                  ),
                  child: Text(
                    _errorMessage!,
                    style: NeoTypography.bodySm.copyWith(color: NeoColors.error),
                  ),
                ),
                const SizedBox(height: NeoSpacing.spaceSm),
              ],

              // Scrollable Form Body
              Expanded(
                child: ListView(
                  children: [
                    // Field 1: Sprint Name
                    NeoTextField(
                      controller: _nameController,
                      labelText: 'Nom du cycle / sprint',
                      hintText: 'Ex: Sprint 5 — Production & Lancement',
                    ),
                    const SizedBox(height: NeoSpacing.spaceSm),

                    // Quick suggestions
                    Wrap(
                      spacing: 6,
                      children: [
                        Text('Suggéré :', style: NeoTypography.labelSm.copyWith(color: NeoColors.muted)),
                        _buildSuggestionChip('Déploiement Capsule Q3'),
                        _buildSuggestionChip('Optimisations & Recette'),
                      ],
                    ),
                    const SizedBox(height: NeoSpacing.spaceMd),

                    // Field 2: Cadence & Period
                    Container(
                      padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceContainerLow,
                        borderRadius: NeoSpacing.roundedLg,
                        border: Border.all(color: NeoColors.borderWhisper),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Rythme & Fréquence', style: NeoTypography.headlineSm),
                              Text(
                                '${_cadenceDays ~/ 7} semaine(s) (${_cadenceDays}j)',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: NeoColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: NeoSpacing.spaceSm),
                          Row(
                            children: [
                              Expanded(
                                child: _buildCadenceButton(
                                  label: '1 sem.',
                                  sublabel: 'Flash (7j)',
                                  days: 7,
                                ),
                              ),
                              const SizedBox(width: NeoSpacing.spaceSm),
                              Expanded(
                                child: _buildCadenceButton(
                                  label: '2 sem.',
                                  sublabel: 'Optimal (14j)',
                                  days: 14,
                                ),
                              ),
                              const SizedBox(width: NeoSpacing.spaceSm),
                              Expanded(
                                child: _buildCadenceButton(
                                  label: '1 mois',
                                  sublabel: 'Projet (30j)',
                                  days: 30,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: NeoSpacing.spaceMd),

                          // Dates summary
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date de début', style: NeoTypography.labelSm),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: NeoColors.surfaceContainerLowest,
                                        borderRadius: NeoSpacing.roundedSm,
                                        border: Border.all(color: NeoColors.borderWhisper),
                                      ),
                                      child: Text(
                                        dateFormatter.format(_startDate),
                                        style: GoogleFonts.jetBrainsMono(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: NeoSpacing.spaceMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date de fin', style: NeoTypography.labelSm),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: NeoColors.surfaceContainerLowest,
                                        borderRadius: NeoSpacing.roundedSm,
                                        border: Border.all(color: NeoColors.borderWhisper),
                                      ),
                                      child: Text(
                                        dateFormatter.format(_endDate),
                                        style: GoogleFonts.jetBrainsMono(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: NeoSpacing.spaceMd),

                    // Field 3: Sprint Goal
                    NeoTextField(
                      controller: _goalController,
                      labelText: 'Objectif principal du cycle (Sprint Goal)',
                      hintText: 'Ex: Finaliser la refonte graphique et valider la campagne de marque...',
                      maxLines: 2,
                    ),
                    const SizedBox(height: NeoSpacing.spaceMd),

                    // Field 4: Backlog Tickets Selector
                    backlogAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (err, stack) => const SizedBox.shrink(),
                      data: (backlog) {
                        final selectedTickets = backlog
                            .where((t) => _selectedBacklogTicketIds.contains(t.id))
                            .toList();
                        final totalPts = selectedTickets.fold<int>(
                          0,
                          (sum, t) => sum + (t.storyPoints ?? 0),
                        );

                        return Container(
                          padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                          decoration: BoxDecoration(
                            color: NeoColors.surfaceContainerLow,
                            borderRadius: NeoSpacing.roundedLg,
                            border: Border.all(color: NeoColors.borderWhisper),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tickets du Backlog à inclure',
                                    style: NeoTypography.headlineSm,
                                  ),
                                  Text(
                                    '${selectedTickets.length} tâche(s) · $totalPts pts',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: NeoColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: NeoSpacing.spaceSm),
                              if (backlog.isEmpty)
                                Text(
                                  'Aucun ticket disponible dans le backlog.',
                                  style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                                )
                              else
                                Container(
                                  constraints: const BoxConstraints(maxHeight: 180),
                                  decoration: BoxDecoration(
                                    color: NeoColors.surfaceContainerLowest,
                                    borderRadius: NeoSpacing.roundedMd,
                                    border: Border.all(color: NeoColors.borderWhisper),
                                  ),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: backlog.length,
                                    separatorBuilder: (context, index) => const Divider(
                                      height: 1,
                                      color: NeoColors.borderWhisper,
                                    ),
                                    itemBuilder: (context, index) {
                                      final t = backlog[index];
                                      final isChecked = _selectedBacklogTicketIds.contains(t.id);
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (isChecked) {
                                              _selectedBacklogTicketIds.remove(t.id);
                                            } else {
                                              _selectedBacklogTicketIds.add(t.id);
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              DenseCheckbox(
                                                value: isChecked,
                                                onChanged: (_) {
                                                  setState(() {
                                                    if (isChecked) {
                                                      _selectedBacklogTicketIds.remove(t.id);
                                                    } else {
                                                      _selectedBacklogTicketIds.add(t.id);
                                                    }
                                                  });
                                                },
                                              ),
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
                                                  style: NeoTypography.bodySm,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (t.storyPoints != null) ...[
                                                const SizedBox(width: NeoSpacing.spaceSm),
                                                Text(
                                                  '${t.storyPoints} pts',
                                                  style: GoogleFonts.jetBrainsMono(
                                                    fontSize: 11,
                                                    color: NeoColors.muted,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: NeoSpacing.spaceMd),

                    // Checkbox Start Immediately
                    CheckboxListTile(
                      value: _startImmediately,
                      onChanged: (val) => setState(() => _startImmediately = val ?? false),
                      title: Text(
                        'Démarrer immédiatement ce sprint',
                        style: NeoTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Le sprint passera au statut Actif dès sa création.',
                        style: NeoTypography.labelSm.copyWith(color: NeoColors.muted),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: NeoColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NeoSpacing.spaceMd),

              // Actions Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NeoButton(
                    label: 'Annuler',
                    variant: NeoButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  NeoButton(
                    label: 'Créer le sprint',
                    isLoading: _isLoading,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return InkWell(
      onTap: () => setState(() => _nameController.text = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: NeoColors.surfaceContainerHigh,
          borderRadius: NeoSpacing.roundedSm,
        ),
        child: Text(text, style: NeoTypography.labelSm),
      ),
    );
  }

  Widget _buildCadenceButton({
    required String label,
    required String sublabel,
    required int days,
  }) {
    final isSelected = _cadenceDays == days;
    return InkWell(
      onTap: () => _setCadence(days),
      borderRadius: NeoSpacing.roundedMd,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? NeoColors.surfaceContainerLowest
              : Colors.transparent,
          borderRadius: NeoSpacing.roundedMd,
          border: Border.all(
            color: isSelected ? NeoColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: NeoTypography.labelSm.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            Text(
              sublabel,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: isSelected ? NeoColors.secondary : NeoColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
