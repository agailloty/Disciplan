import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/widgets/kbd_chip.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/neo_card.dart';
import 'package:disciplaner_flutter/core/widgets/neo_text_field.dart';
import 'project_providers.dart';

class CreateProjectModal extends ConsumerStatefulWidget {
  const CreateProjectModal({super.key});

  static Future<ProjectDetailDto?> show(BuildContext context) {
    return showDialog<ProjectDetailDto>(
      context: context,
      barrierColor: Colors.black45,
      builder: (context) => const CreateProjectModal(),
    );
  }

  @override
  ConsumerState<CreateProjectModal> createState() => _CreateProjectModalState();
}

class _CreateProjectModalState extends ConsumerState<CreateProjectModal> {
  final _nameController = TextEditingController();
  final _keyController = TextEditingController();
  final _descriptionController = TextEditingController();

  TicketType _defaultType = TicketType.task;
  DefaultAssigneePolicy _defaultPolicy = DefaultAssigneePolicy.none;

  bool _isManualKey = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      if (!_isManualKey) {
        final autoKey = generateProjectKey(_nameController.text);
        _keyController.text = autoKey;
      }
    });
    _keyController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final key = _keyController.text.trim().toUpperCase();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Veuillez saisir le nom du projet.');
      return;
    }

    if (key.length < 2 || key.length > 10) {
      setState(() => _errorMessage = 'La clé doit comporter entre 2 et 10 caractères.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(projectRepositoryProvider);
      final created = await repo.create(
        CreateProjectRequest(
          name: name,
          key: key,
          description: description.isNotEmpty ? description : null,
        ),
      );

      // Si defaults différents, update
      if (_defaultType != TicketType.story || _defaultPolicy != DefaultAssigneePolicy.none) {
        try {
          await repo.updateDefaults(
            created.id,
            UpdateProjectDefaultsRequest(
              defaultTicketType: _defaultType,
              defaultAssigneePolicy: _defaultPolicy,
            ),
          );
        } catch (_) {}
      }

      ref.invalidate(projectsListProvider);
      ref.read(selectedProjectIdProvider.notifier).select(created.id);

      if (mounted) {
        Navigator.of(context).pop(created);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(NeoSpacing.spaceLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: NeoCard(
          hasOverlayShadow: true,
          padding: const EdgeInsets.all(NeoSpacing.spaceXl),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: NeoColors.kineticAmber,
                        ),
                      ),
                      const SizedBox(width: NeoSpacing.spaceSm),
                      Text(
                        'INITIATION AGILE',
                        style: NeoTypography.labelSm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: NeoColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const KbdChip(label: 'ESC'),
                ],
              ),
              const SizedBox(height: NeoSpacing.spaceSm),
              Text('Créer un nouveau projet', style: NeoTypography.headlineLg),
              const SizedBox(height: NeoSpacing.spaceXs),
              Text(
                'Configurez un espace de travail collaboratif pour aligner vos sprints et tickets.',
                style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
              ),
              const SizedBox(height: NeoSpacing.spaceLg),

              // Form fields
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: NeoTextField(
                      controller: _nameController,
                      labelText: 'NOM DU PROJET *',
                      hintText: 'ex. Campagne de Marque 2025',
                      autofocus: true,
                    ),
                  ),
                  const SizedBox(width: NeoSpacing.spaceMd),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CLÉ *',
                              style: NeoTypography.headlineSm.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: NeoColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'AUTO',
                              style: NeoTypography.labelSm.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: NeoSpacing.spaceXs),
                        TextField(
                          controller: _keyController,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 10,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                          onChanged: (_) => _isManualKey = true,
                          decoration: InputDecoration(
                            isDense: true,
                            counterText: '',
                            filled: true,
                            fillColor: NeoColors.surfaceContainerLowest,
                            prefixText: '# ',
                            prefixStyle: NeoTypography.labelMd.copyWith(color: NeoColors.muted),
                            suffixText: _keyController.text.isNotEmpty ? '${_keyController.text}-1' : '',
                            suffixStyle: NeoTypography.labelSm.copyWith(
                              color: NeoColors.secondary,
                              backgroundColor: NeoColors.secondaryContainer.withValues(alpha: 0.2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                            border: const OutlineInputBorder(
                              borderRadius: NeoSpacing.roundedSm,
                              borderSide: BorderSide(color: NeoColors.borderWhisper),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: NeoSpacing.roundedSm,
                              borderSide: BorderSide(color: NeoColors.borderWhisper),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: NeoSpacing.roundedSm,
                              borderSide: BorderSide(color: NeoColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NeoSpacing.spaceMd),
              NeoTextField(
                controller: _descriptionController,
                labelText: 'DESCRIPTION & VISION',
                hintText: 'Résumez les objectifs stratégiques et le périmètre...',
                maxLines: 3,
              ),
              const SizedBox(height: NeoSpacing.spaceMd),

              // Defaults selector
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TYPE PAR DÉFAUT',
                          style: NeoTypography.headlineSm.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: NeoColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<TicketType>(
                          initialValue: _defaultType,
                          decoration: const InputDecoration(isDense: true),
                          items: TicketType.values.map((t) {
                            return DropdownMenuItem(
                              value: t,
                              child: Text(t.name.toUpperCase(), style: NeoTypography.bodySm),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _defaultType = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: NeoSpacing.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ASSIGNATION PAR DÉFAUT',
                          style: NeoTypography.headlineSm.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: NeoColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<DefaultAssigneePolicy>(
                          initialValue: _defaultPolicy,
                          decoration: const InputDecoration(isDense: true),
                          items: DefaultAssigneePolicy.values.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text(
                                p == DefaultAssigneePolicy.creator ? 'Créateur' : 'Aucun',
                                style: NeoTypography.bodySm,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _defaultPolicy = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: NeoSpacing.spaceMd),
                Container(
                  padding: const EdgeInsets.all(NeoSpacing.spaceSm),
                  decoration: BoxDecoration(
                    color: NeoColors.error.withValues(alpha: 0.08),
                    borderRadius: NeoSpacing.roundedSm,
                    border: Border.all(color: NeoColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: NeoTypography.bodySm.copyWith(color: NeoColors.error),
                  ),
                ),
              ],

              const SizedBox(height: NeoSpacing.spaceLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NeoButton(
                    label: 'Annuler',
                    variant: NeoButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  NeoButton(
                    label: 'Créer le projet',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
