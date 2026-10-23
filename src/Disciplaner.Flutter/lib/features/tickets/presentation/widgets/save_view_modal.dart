import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/models/collaboration_models.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/neo_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ticket_providers.dart';

class SaveViewModal extends ConsumerStatefulWidget {
  final StatusCategory? initialCategory;
  final CardPriority? initialPriority;

  const SaveViewModal({
    super.key,
    this.initialCategory,
    this.initialPriority,
  });

  static Future<void> show(
    BuildContext context, {
    StatusCategory? initialCategory,
    CardPriority? initialPriority,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (context) => SaveViewModal(
        initialCategory: initialCategory,
        initialPriority: initialPriority,
      ),
    );
  }

  @override
  ConsumerState<SaveViewModal> createState() => _SaveViewModalState();
}

class _SaveViewModalState extends ConsumerState<SaveViewModal> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _onlyAssignedToMe = true;
  bool _isVisibleOnHome = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = context.l10n.ticketsViewNameRequired);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(savedViewRepositoryProvider);
      await repo.create(
        CreateSavedViewRequest(
          name: name,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          isVisibleOnHome: _isVisibleOnHome,
          onlyAssignedToMe: _onlyAssignedToMe,
          statusCategories: widget.initialCategory != null
              ? [widget.initialCategory!]
              : [],
          priority: widget.initialPriority,
        ),
      );

      ref.invalidate(savedViewsListProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.ticketsViewSaved)),
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
    final l10n = context.l10n;
    return Dialog(
      backgroundColor: NeoColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: NeoSpacing.roundedXl,
        side: const BorderSide(color: NeoColors.borderWhisper),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(NeoSpacing.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bookmark_add_outlined,
                        size: 20,
                        color: NeoColors.primary,
                      ),
                      const SizedBox(width: NeoSpacing.spaceSm),
                      Text(
                        l10n.ticketsSaveAsViewTitle,
                        style: NeoTypography.headlineSm,
                      ),
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

              NeoTextField(
                controller: _nameController,
                labelText: l10n.ticketsViewNameLabel,
                hintText: l10n.ticketsViewNameHint,
              ),
              const SizedBox(height: NeoSpacing.spaceMd),

              NeoTextField(
                controller: _descriptionController,
                labelText: l10n.ticketsViewDescriptionLabel,
                hintText: l10n.ticketsViewDescriptionHint,
              ),
              const SizedBox(height: NeoSpacing.spaceMd),

              CheckboxListTile(
                value: _onlyAssignedToMe,
                onChanged: (val) =>
                    setState(() => _onlyAssignedToMe = val ?? false),
                title: Text(
                  l10n.savedviewOnlyAssignedToMe,
                  style: NeoTypography.bodySm,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: NeoColors.primary,
              ),

              CheckboxListTile(
                value: _isVisibleOnHome,
                onChanged: (val) =>
                    setState(() => _isVisibleOnHome = val ?? false),
                title: Text(
                  l10n.ticketsPinToHome,
                  style: NeoTypography.bodySm,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: NeoColors.primary,
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
                    isLoading: _isLoading,
                    onPressed: _handleSave,
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
