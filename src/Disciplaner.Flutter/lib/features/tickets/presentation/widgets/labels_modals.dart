import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/neo_text_field.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../label_providers.dart';
import '../ticket_providers.dart';

/// Palette de couleurs proposées pour les étiquettes.
const List<String> kLabelColorPalette = [
  '#E5A800', '#F59E0B', '#EF4444', '#EC4899', '#8B5CF6',
  '#6366F1', '#3B82F6', '#06B6D4', '#10B981', '#84CC16', '#64748B',
];

/// Convertit un code couleur `#RRGGBB` en [Color].
Color parseLabelColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  final value = int.tryParse('FF$cleaned') ?? 0xFFE5A800;
  return Color(value);
}

/// Modale de création / modification d'étiquette (réservée aux admins côté
/// API). `existing` null = création.
class LabelEditModal extends ConsumerStatefulWidget {
  final LabelDto? existing;
  final ValueChanged<LabelDto> onSaved;

  const LabelEditModal({super.key, this.existing, required this.onSaved});

  static Future<void> show(
    BuildContext context, {
    LabelDto? existing,
    required ValueChanged<LabelDto> onSaved,
  }) {
    return showDialog(
      context: context,
      builder: (context) => LabelEditModal(
        existing: existing,
        onSaved: onSaved,
      ),
    );
  }

  @override
  ConsumerState<LabelEditModal> createState() => _LabelEditModalState();
}

class _LabelEditModalState extends ConsumerState<LabelEditModal> {
  late final TextEditingController _nameController;
  late String _selectedColor;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _selectedColor = widget.existing?.color ?? kLabelColorPalette.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(labelRepositoryProvider);
      final label = widget.existing == null
          ? await repo.createLabel(name: name, color: _selectedColor)
          : await repo.updateLabel(
              widget.existing!.id,
              name: name,
              color: _selectedColor,
            );
      ref.invalidate(labelsListProvider);
      if (mounted) {
        widget.onSaved(label);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = _nameController.text.trim();

    return Dialog(
      backgroundColor: NeoColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: NeoSpacing.roundedXl,
        side: const BorderSide(color: NeoColors.borderWhisper),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(NeoSpacing.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null
                    ? l10n.labelCreateTitle
                    : l10n.labelEditTitle,
                style: NeoTypography.headlineSm,
              ),
              const SizedBox(height: NeoSpacing.spaceMd),
              NeoTextField(
                controller: _nameController,
                labelText: l10n.labelName.toUpperCase(),
                isDense: true,
                autofocus: widget.existing == null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: NeoSpacing.spaceMd),
              Text(
                l10n.labelColor.toUpperCase(),
                style: NeoTypography.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: NeoColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: NeoSpacing.spaceSm),
              Wrap(
                spacing: NeoSpacing.spaceSm,
                runSpacing: NeoSpacing.spaceSm,
                children: kLabelColorPalette.map((hex) {
                  final color = parseLabelColor(hex);
                  final isSelected = hex == _selectedColor;
                  return InkWell(
                    borderRadius: NeoSpacing.roundedFull,
                    onTap: () => setState(() => _selectedColor = hex),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? NeoColors.onSurface
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: NeoSpacing.spaceMd),
              Text(
                l10n.labelPreview.toUpperCase(),
                style: NeoTypography.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: NeoColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: NeoSpacing.spaceXs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: parseLabelColor(_selectedColor).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: parseLabelColor(_selectedColor).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  name.isEmpty ? l10n.labelName : name,
                  style: NeoTypography.labelSm.copyWith(
                    color: parseLabelColor(_selectedColor),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: NeoSpacing.spaceLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NeoButton(
                    label: l10n.cancel,
                    variant: NeoButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  NeoButton(
                    label: l10n.save,
                    isLoading: _isSaving,
                    onPressed: name.isEmpty ? null : _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modale de sélection des étiquettes d'un ticket : coche / décoche pour
/// attacher ou détacher, champ de filtre, et création directe pour les
/// administrateurs.
class LabelPickerModal extends ConsumerStatefulWidget {
  final TicketDto ticket;

  const LabelPickerModal({super.key, required this.ticket});

  static Future<void> show(BuildContext context, TicketDto ticket) {
    return showDialog(
      context: context,
      builder: (context) => LabelPickerModal(ticket: ticket),
    );
  }

  @override
  ConsumerState<LabelPickerModal> createState() => _LabelPickerModalState();
}

class _LabelPickerModalState extends ConsumerState<LabelPickerModal> {
  final _filterController = TextEditingController();
  late Set<String> _attachedIds;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _attachedIds = widget.ticket.labels.map((l) => l.id).toSet();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  bool get _isAdmin {
    final authState = ref.read(authNotifierProvider);
    final session = authState is AuthAuthenticated ? authState.session : null;
    return session?.roles.contains('Admin') ?? false;
  }

  Future<void> _toggle(LabelDto label) async {
    if (_isBusy) return;
    final isAttached = _attachedIds.contains(label.id);
    setState(() => _isBusy = true);
    try {
      final repo = ref.read(ticketRepositoryProvider);
      if (isAttached) {
        await repo.removeLabel(widget.ticket.id, label.id);
        _attachedIds.remove(label.id);
      } else {
        await repo.addLabel(widget.ticket.id, label.id);
        _attachedIds.add(label.id);
      }
      ref.invalidate(ticketDetailProvider(widget.ticket.id));
      if (mounted) setState(() => _isBusy = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isBusy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _createAndAttach() async {
    await LabelEditModal.show(
      context,
      onSaved: (label) async {
        try {
          final repo = ref.read(ticketRepositoryProvider);
          await repo.addLabel(widget.ticket.id, label.id);
          _attachedIds.add(label.id);
          ref.invalidate(ticketDetailProvider(widget.ticket.id));
          if (mounted) setState(() {});
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labelsAsync = ref.watch(labelsListProvider);
    final filter = _filterController.text.trim().toLowerCase();

    return Dialog(
      backgroundColor: NeoColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: NeoSpacing.roundedXl,
        side: const BorderSide(color: NeoColors.borderWhisper),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(NeoSpacing.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.labelTitle, style: NeoTypography.headlineSm),
              const SizedBox(height: NeoSpacing.spaceMd),
              NeoTextField(
                controller: _filterController,
                hintText: l10n.labelpickerFilter,
                isDense: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: NeoSpacing.spaceMd),
              Flexible(
                child: labelsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (e, _) => Text(
                    e.toString(),
                    style: NeoTypography.bodySm.copyWith(color: NeoColors.error),
                  ),
                  data: (labels) {
                    final visible = filter.isEmpty
                        ? labels
                        : labels
                            .where((l) =>
                                l.name.toLowerCase().contains(filter))
                            .toList();

                    if (visible.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                        child: Text(
                          l10n.labelpickerEmpty,
                          style: NeoTypography.bodySm
                              .copyWith(color: NeoColors.muted),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: visible.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        color: NeoColors.surfaceContainerHigh,
                      ),
                      itemBuilder: (context, index) {
                        final label = visible[index];
                        final isAttached = _attachedIds.contains(label.id);
                        return InkWell(
                          borderRadius: NeoSpacing.roundedSm,
                          onTap: () => _toggle(label),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: NeoSpacing.spaceXs,
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isAttached,
                                  activeColor: NeoColors.primary,
                                  onChanged: (_) => _toggle(label),
                                ),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: parseLabelColor(label.color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: NeoSpacing.spaceSm),
                                Expanded(
                                  child: Text(
                                    label.name,
                                    style: NeoTypography.bodyMd,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isAttached)
                                  Text(
                                    l10n.labelpickerRemove,
                                    style: NeoTypography.labelSm.copyWith(
                                      color: NeoColors.muted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (_isAdmin) ...[
                const SizedBox(height: NeoSpacing.spaceMd),
                NeoButton(
                  label: l10n.labelCreateTitle,
                  variant: NeoButtonVariant.secondary,
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: _createAndAttach,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
