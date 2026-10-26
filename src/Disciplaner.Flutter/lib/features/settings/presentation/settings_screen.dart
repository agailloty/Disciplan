import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/enum_l10n.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/l10n/locale_providers.dart';
import 'package:disciplaner_flutter/core/models/collaboration_models.dart';
import 'package:disciplaner_flutter/core/shortcuts/app_shortcuts.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/settings/presentation/mcp_tokens_section.dart';
import 'package:disciplaner_flutter/features/settings/presentation/settings_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/label_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/labels_modals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _displayNameController = TextEditingController();
  final _serverUrlController = TextEditingController();
  final _inviteEmailController = TextEditingController();
  final _customScaleController = TextEditingController(text: '100');

  bool _isSavingDisplayName = false;
  bool _isCreatingInvite = false;
  String? _lastCreatedInviteUrl;
  bool _profileMessageVisible = false;
  bool _profileSuccess = true;
  Object? _profileError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authNotifierProvider);
      if (authState is AuthAuthenticated) {
        _displayNameController.text = authState.session.displayName;
      }
      final serverUrl = ref.read(homelabServerUrlProvider);
      _serverUrlController.text = serverUrl;
      final currentScale = ref.read(uiScaleProvider);
      _customScaleController.text = '${(currentScale * 100).round()}';
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _serverUrlController.dispose();
    _inviteEmailController.dispose();
    _customScaleController.dispose();
    super.dispose();
  }

  Future<void> _updateDisplayName() async {
    final newName = _displayNameController.text.trim();
    if (newName.isEmpty) return;

    setState(() {
      _isSavingDisplayName = true;
      _profileMessageVisible = false;
      _profileError = null;
    });

    try {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.updateDisplayName(newName);
      await ref.read(authNotifierProvider.notifier).updateDisplayNameLocal(newName);
      if (mounted) {
        setState(() {
          _profileSuccess = true;
          _profileMessageVisible = true;
          _profileError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _profileSuccess = false;
          _profileMessageVisible = true;
          _profileError = e;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingDisplayName = false;
        });
      }
    }
  }

  Future<void> _applyServerUrl() async {
    final url = _serverUrlController.text.trim();
    if (url.isEmpty) return;
    final success = await ref.read(authNotifierProvider.notifier).updateServerUrl(url);
    if (mounted) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? l10n.settingsServerUrlUpdated : l10n.settingsServerUnreachable,
            style: NeoTypography.bodySm.copyWith(color: Colors.white),
          ),
          backgroundColor: success ? NeoColors.primary : NeoColors.error,
        ),
      );
    }
  }

  Future<void> _createInvitation() async {
    final email = _inviteEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsInviteEmailInvalid),
          backgroundColor: NeoColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingInvite = true;
    });

    try {
      final repo = ref.read(settingsRepositoryProvider);
      final invite = await repo.createInvitation(email);
      ref.invalidate(adminInvitationsListProvider);
      _inviteEmailController.clear();

      final serverUrl = ref.read(homelabServerUrlProvider);
      final inviteUrl = '$serverUrl/invite?token=${invite.token}';

      setState(() {
        _lastCreatedInviteUrl = inviteUrl;
      });

      if (mounted) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsInviteGenerated(email)),
            backgroundColor: NeoColors.emerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsInviteError(e.toString())),
            backgroundColor: NeoColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingInvite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authNotifierProvider);
    final session = authState is AuthAuthenticated ? authState.session : null;
    final isAdmin = session?.roles.contains('Admin') ?? false;

    return Scaffold(
      backgroundColor: NeoColors.surfaceContainerLowest,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: NeoSpacing.spaceLg,
          vertical: NeoSpacing.spaceXl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      l10n.settingsTitle,
                      style: NeoTypography.headlineLg,
                    ),
                    const SizedBox(width: NeoSpacing.spaceMd),
                    if (isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: NeoColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: NeoColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          l10n.roleAdmin,
                          style: NeoTypography.labelSm.copyWith(
                            color: NeoColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: NeoSpacing.spaceXs),
                Text(
                  l10n.settingsHeaderSubtitle,
                  style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                ),
                const SizedBox(height: NeoSpacing.spaceXl),

                // Langue
                _buildCardSection(
                  title: l10n.settingsLanguage,
                  subtitle: l10n.settingsLanguageHint,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final currentLocale = ref.watch(localeProvider);
                      return Wrap(
                        spacing: NeoSpacing.spaceSm,
                        runSpacing: NeoSpacing.spaceSm,
                        children: [
                          ChoiceChip(
                            label: Text(
                              l10n.settingsLanguageFr,
                              style: NeoTypography.labelSm.copyWith(
                                color: currentLocale.languageCode == 'fr'
                                    ? Colors.white
                                    : NeoColors.onSurface,
                                fontWeight: currentLocale.languageCode == 'fr'
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            selected: currentLocale.languageCode == 'fr',
                            selectedColor: NeoColors.primary,
                            backgroundColor: NeoColors.surfaceContainerLow,
                            side: BorderSide(
                              color: currentLocale.languageCode == 'fr'
                                  ? NeoColors.primary
                                  : NeoColors.borderWhisper,
                            ),
                            onSelected: (_) {
                              ref.read(localeProvider.notifier).set(const Locale('fr'));
                            },
                          ),
                          ChoiceChip(
                            label: Text(
                              l10n.settingsLanguageEn,
                              style: NeoTypography.labelSm.copyWith(
                                color: currentLocale.languageCode == 'en'
                                    ? Colors.white
                                    : NeoColors.onSurface,
                                fontWeight: currentLocale.languageCode == 'en'
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            selected: currentLocale.languageCode == 'en',
                            selectedColor: NeoColors.primary,
                            backgroundColor: NeoColors.surfaceContainerLow,
                            side: BorderSide(
                              color: currentLocale.languageCode == 'en'
                                  ? NeoColors.primary
                                  : NeoColors.borderWhisper,
                            ),
                            onSelected: (_) {
                              ref.read(localeProvider.notifier).set(const Locale('en'));
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: NeoSpacing.spaceLg),

                // 0. Affichage & Mise à l'échelle (UI Scaling)
                _buildCardSection(
                  title: l10n.settingsScalingTitle,
                  subtitle: l10n.settingsScalingSubtitle,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final currentScale = ref.watch(uiScaleProvider);
                      final currentPercent = (currentScale * 100).round();
                      final presets = [
                        (0.9, l10n.settingsScaleCompact),
                        (1.0, l10n.settingsScaleStandard),
                        (1.1, l10n.settingsScaleComfort),
                        (1.2, l10n.settingsScaleLarge),
                      ];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: NeoSpacing.spaceSm,
                            runSpacing: NeoSpacing.spaceSm,
                            children: presets.map((p) {
                              final isSelected = (currentScale - p.$1).abs() < 0.015;
                              return ChoiceChip(
                                label: Text(
                                  p.$2,
                                  style: NeoTypography.labelSm.copyWith(
                                    color: isSelected ? Colors.white : NeoColors.onSurface,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: NeoColors.primary,
                                backgroundColor: NeoColors.surfaceContainerLow,
                                side: BorderSide(
                                  color: isSelected ? NeoColors.primary : NeoColors.borderWhisper,
                                ),
                                onSelected: (_) {
                                  ref.read(uiScaleProvider.notifier).setScale(p.$1);
                                  _customScaleController.text = '${(p.$1 * 100).round()}';
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: NeoSpacing.spaceMd),
                          Container(
                            padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                            decoration: BoxDecoration(
                              color: NeoColors.surfaceContainerLow,
                              borderRadius: NeoSpacing.roundedMd,
                              border: Border.all(color: NeoColors.borderWhisper),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.settingsScaleFactor,
                                      style: NeoTypography.labelMd.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: NeoColors.kineticAmber.withValues(alpha: 0.16),
                                        borderRadius: NeoSpacing.roundedSm,
                                      ),
                                      child: Text(
                                        '$currentPercent%',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: NeoColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: NeoSpacing.spaceSm),
                                Wrap(
                                  spacing: NeoSpacing.spaceSm,
                                  runSpacing: NeoSpacing.spaceSm,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    IconButton(
                                      tooltip: l10n.settingsScaleDecrease,
                                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        ref.read(uiScaleProvider.notifier).decrease();
                                        final updated = ref.read(uiScaleProvider);
                                        _customScaleController.text = '${(updated * 100).round()}';
                                      },
                                    ),
                                    SizedBox(
                                      width: 240,
                                      child: Slider(
                                        value: currentScale.clamp(0.50, 2.00),
                                        min: 0.50,
                                        max: 2.00,
                                        divisions: 30,
                                        activeColor: NeoColors.primary,
                                        label: '$currentPercent%',
                                        onChanged: (val) {
                                          ref.read(uiScaleProvider.notifier).setScale(val);
                                          _customScaleController.text = '${(val * 100).round()}';
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: l10n.settingsScaleIncrease,
                                      icon: const Icon(Icons.add_circle_outline, size: 18),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        ref.read(uiScaleProvider.notifier).increase();
                                        final updated = ref.read(uiScaleProvider);
                                        _customScaleController.text = '${(updated * 100).round()}';
                                      },
                                    ),
                                    SizedBox(
                                      width: 84,
                                      child: TextField(
                                        controller: _customScaleController,
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          suffixText: '%',
                                          filled: true,
                                          fillColor: NeoColors.surfaceContainerLowest,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: NeoSpacing.roundedSm,
                                            borderSide: const BorderSide(
                                              color: NeoColors.borderWhisper,
                                            ),
                                          ),
                                        ),
                                        onSubmitted: (val) {
                                          final parsed = double.tryParse(
                                            val.replaceAll('%', '').trim(),
                                          );
                                          if (parsed != null) {
                                            final nextScale = (parsed / 100.0).clamp(0.50, 2.00);
                                            ref.read(uiScaleProvider.notifier).setScale(nextScale);
                                            _customScaleController.text =
                                                '${(nextScale * 100).round()}';
                                          }
                                        },
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        final parsed = double.tryParse(
                                          _customScaleController.text.replaceAll('%', '').trim(),
                                        );
                                        if (parsed != null) {
                                          final nextScale = (parsed / 100.0).clamp(0.50, 2.00);
                                          ref.read(uiScaleProvider.notifier).setScale(nextScale);
                                          _customScaleController.text =
                                              '${(nextScale * 100).round()}';
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: NeoColors.secondary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      child: Text(l10n.settingsApply),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ref.read(uiScaleProvider.notifier).reset();
                                        _customScaleController.text = '100';
                                      },
                                      child: Text(l10n.settingsScaleReset),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: NeoSpacing.spaceSm),
                          Text(
                            l10n.settingsScaleHint,
                            style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: NeoSpacing.spaceLg),

                // 1. Profil Section
                _buildCardSection(
                  title: l10n.settingsProfileTitle,
                  subtitle: l10n.settingsProfileSubtitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          UserAvatar(
                            name: session?.displayName ?? l10n.settingsDefaultUser,
                            size: 48,
                          ),
                          const SizedBox(width: NeoSpacing.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session?.displayName ?? l10n.settingsDefaultUser,
                                  style: NeoTypography.headlineSm,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  session?.email ?? l10n.settingsNotConnected,
                                  style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: NeoSpacing.spaceLg),
                      Text(
                        l10n.settingsDisplayName,
                        style: NeoTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: NeoSpacing.spaceSm),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _displayNameController,
                              style: NeoTypography.bodyMd,
                              decoration: InputDecoration(
                                hintText: l10n.settingsDisplayNamePlaceholder,
                                isDense: true,
                                filled: true,
                                fillColor: NeoColors.surfaceContainerLowest,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: NeoSpacing.spaceMd,
                                  vertical: NeoSpacing.spaceSm,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: NeoColors.borderWhisper),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: NeoColors.borderWhisper),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(color: NeoColors.secondary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: NeoSpacing.spaceMd),
                          ElevatedButton(
                            onPressed: _isSavingDisplayName ? null : _updateDisplayName,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NeoColors.secondary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: _isSavingDisplayName
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(l10n.save),
                          ),
                        ],
                      ),
                      if (_profileMessageVisible) ...[
                        const SizedBox(height: NeoSpacing.spaceSm),
                        Text(
                          _profileSuccess
                              ? l10n.settingsDisplayNameSaved
                              : l10n.settingsUpdateError(_profileError.toString()),
                          style: NeoTypography.bodySm.copyWith(
                            color: _profileSuccess ? NeoColors.emerald : NeoColors.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: NeoSpacing.spaceLg),
                      const Divider(height: 1, color: NeoColors.surfaceContainerHigh),
                      const SizedBox(height: NeoSpacing.spaceLg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.settingsSessionTitle,
                                  style: NeoTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  l10n.settingsSessionSubtitle,
                                  style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: NeoSpacing.spaceMd),
                          OutlinedButton.icon(
                            onPressed: () {
                              ref.read(authNotifierProvider.notifier).logout();
                            },
                            icon: const Icon(Icons.logout, size: 16, color: NeoColors.error),
                            label: Text(
                              l10n.navLogout,
                              style: NeoTypography.labelMd.copyWith(color: NeoColors.error),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: NeoColors.error),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NeoSpacing.spaceLg),

                // 2. Serveur Homelab
                _buildCardSection(
                  title: l10n.settingsServerTitle,
                  subtitle: l10n.settingsServerSubtitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _serverUrlController,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 13,
                                color: NeoColors.secondary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'http://homelab.local:5000',
                                isDense: true,
                                filled: true,
                                fillColor: NeoColors.surfaceContainerLowest,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: NeoSpacing.spaceMd,
                                  vertical: NeoSpacing.spaceSm,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: NeoColors.borderWhisper),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: NeoColors.borderWhisper),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(color: NeoColors.secondary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: NeoSpacing.spaceMd),
                          ElevatedButton(
                            onPressed: _applyServerUrl,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NeoColors.secondary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: Text(l10n.settingsApply),
                          ),
                        ],
                      ),
                      const SizedBox(height: NeoSpacing.spaceSm),
                      Text(
                        l10n.settingsServerHint,
                        style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NeoSpacing.spaceLg),

                // 3. Vues Sauvegardées
                _buildCardSection(
                  title: l10n.settingsSavedViewsTitle,
                  subtitle: l10n.settingsSavedViewsSubtitle,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final savedViewsAsync = ref.watch(savedViewsListProvider);

                      return savedViewsAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(NeoSpacing.spaceMd),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (err, _) => Padding(
                          padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                          child: Text(
                            l10n.settingsSavedViewsError(err.toString()),
                            style: NeoTypography.bodySm.copyWith(color: NeoColors.error),
                          ),
                        ),
                        data: (views) {
                          if (views.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: NeoSpacing.spaceMd),
                              child: Text(
                                l10n.settingsSavedViewsEmpty,
                                style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: views.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              color: NeoColors.surfaceContainerHigh,
                            ),
                            itemBuilder: (context, index) {
                              final view = views[index];
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  view.isVisibleOnHome ? Icons.push_pin : Icons.push_pin_outlined,
                                  size: 18,
                                  color: view.isVisibleOnHome ? NeoColors.primary : NeoColors.muted,
                                ),
                                title: Text(view.name, style: NeoTypography.labelMd),
                                subtitle: Text(
                                  l10n.settingsSavedViewSummary(
                                    view.projectId ?? l10n.settingsAll,
                                    view.type?.localizedLabel(l10n) ?? l10n.settingsAll,
                                  ),
                                  style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        view.isVisibleOnHome ? Icons.star : Icons.star_border,
                                        size: 18,
                                        color: view.isVisibleOnHome ? NeoColors.primary : NeoColors.muted,
                                      ),
                                      tooltip: view.isVisibleOnHome ? l10n.settingsUnpin : l10n.settingsPin,
                                      onPressed: () async {
                                        final repo = ref.read(savedViewRepositoryProvider);
                                        await repo.update(
                                          view.id,
                                          CreateSavedViewRequest(
                                            name: view.name,
                                            description: view.description,
                                            projectId: view.projectId,
                                            statusId: view.statusId,
                                            sprintId: view.sprintId,
                                            type: view.type,
                                            priority: view.priority,
                                            statusCategories: view.statusCategories,
                                            onlyAssignedToMe: view.onlyAssignedToMe,
                                            onlyReportedByMe: view.onlyReportedByMe,
                                            isCollapsedByDefault: view.isCollapsedByDefault,
                                            isVisibleOnHome: !view.isVisibleOnHome,
                                            displayOrder: view.displayOrder,
                                          ),
                                        );
                                        ref.invalidate(savedViewsListProvider);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: NeoColors.error,
                                      ),
                                      tooltip: l10n.delete,
                                      onPressed: () async {
                                        final repo = ref.read(savedViewRepositoryProvider);
                                        await repo.delete(view.id);
                                        ref.invalidate(savedViewsListProvider);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // 3bis. Jetons MCP (connecteur IA)
                const SizedBox(height: NeoSpacing.spaceLg),
                const McpTokensSection(),

                // 4. Administration (si rôle Admin)
                if (isAdmin) ...[
                  const SizedBox(height: NeoSpacing.spaceLg),
                  _buildCardSection(
                    title: l10n.settingsAdminInvitationsTitle,
                    subtitle: l10n.settingsAdminInvitationsSubtitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _inviteEmailController,
                                style: NeoTypography.bodyMd,
                                decoration: InputDecoration(
                                  hintText: l10n.settingsInviteEmailHint,
                                  isDense: true,
                                  filled: true,
                                  fillColor: NeoColors.surfaceContainerLowest,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: NeoSpacing.spaceMd,
                                    vertical: NeoSpacing.spaceSm,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(color: NeoColors.borderWhisper),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(color: NeoColors.borderWhisper),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: const BorderSide(color: NeoColors.secondary),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: NeoSpacing.spaceMd),
                            ElevatedButton.icon(
                              onPressed: _isCreatingInvite ? null : _createInvitation,
                              icon: const Icon(Icons.link, size: 16),
                              label: Text(l10n.settingsGenerateInviteLink),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NeoColors.primary,
                                foregroundColor: NeoColors.secondary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                        if (_lastCreatedInviteUrl != null) ...[
                          const SizedBox(height: NeoSpacing.spaceMd),
                          Container(
                            padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                            decoration: BoxDecoration(
                              color: NeoColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: NeoColors.primary.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: NeoColors.emerald, size: 20),
                                const SizedBox(width: NeoSpacing.spaceSm),
                                Expanded(
                                  child: SelectableText(
                                    _lastCreatedInviteUrl!,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 12,
                                      color: NeoColors.secondary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18),
                                  tooltip: l10n.adminInviteCopyLink,
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: _lastCreatedInviteUrl!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.settingsInviteLinkCopied),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: NeoSpacing.spaceLg),
                        Text(
                          l10n.settingsPendingInvitations,
                          style: NeoTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: NeoSpacing.spaceSm),
                        Consumer(
                          builder: (context, ref, _) {
                            final invitesAsync = ref.watch(adminInvitationsListProvider);

                            return invitesAsync.when(
                              loading: () => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              error: (e, _) => Text(
                                l10n.settingsInvitationsError(e.toString()),
                                style: NeoTypography.bodySm.copyWith(color: NeoColors.error),
                              ),
                              data: (invites) {
                                if (invites.isEmpty) {
                                  return Text(
                                    l10n.adminInvitationsEmpty,
                                    style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                                  );
                                }

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: invites.length,
                                  separatorBuilder: (context, index) => const Divider(
                                    height: 1,
                                    color: NeoColors.surfaceContainerHigh,
                                  ),
                                  itemBuilder: (context, index) {
                                    final inv = invites[index];
                                    final isExpired = inv.expiresAt.isBefore(DateTime.now());
                                    return ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(inv.email, style: NeoTypography.labelMd),
                                      subtitle: Text(
                                        '${l10n.adminInviteExpiresOn} ${inv.expiresAt.day}/${inv.expiresAt.month}/${inv.expiresAt.year} • ${inv.isUsed ? l10n.settingsInviteUsed : (isExpired ? l10n.settingsInviteExpired : l10n.settingsInviteValid)}',
                                        style: NeoTypography.bodySm.copyWith(
                                          color: inv.isUsed
                                              ? NeoColors.muted
                                              : (isExpired ? NeoColors.error : NeoColors.emerald),
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.copy, size: 16),
                                        tooltip: l10n.settingsCopyToken,
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: inv.token));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(l10n.settingsTokenCopied),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: NeoSpacing.spaceLg),

                  // 5. Administration — Utilisateurs
                  _buildCardSection(
                    title: l10n.settingsAdminUsersTitle,
                    subtitle: l10n.settingsAdminUsersSubtitle,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final usersAsync = ref.watch(adminUsersListProvider);

                        return usersAsync.when(
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          error: (e, _) => Text(
                            l10n.settingsUsersError(e.toString()),
                            style: NeoTypography.bodySm.copyWith(color: NeoColors.error),
                          ),
                          data: (users) {
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: users.length,
                              separatorBuilder: (context, index) => const Divider(
                                height: 1,
                                color: NeoColors.surfaceContainerHigh,
                              ),
                              itemBuilder: (context, index) {
                                final u = users[index];
                                final isCurrent = u.email == session?.email;
                                final isAdminUser = u.roles.contains('Admin');

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: UserAvatar(name: u.displayName, size: 36),
                                  title: Row(
                                    children: [
                                      Text(u.displayName, style: NeoTypography.labelMd),
                                      if (isCurrent) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          l10n.settingsYou,
                                          style: NeoTypography.bodySm.copyWith(
                                            color: NeoColors.muted,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: u.isActive
                                              ? NeoColors.emerald.withValues(alpha: 0.1)
                                              : NeoColors.error.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          u.isActive ? l10n.settingsActive : l10n.settingsInactive,
                                          style: NeoTypography.labelSm.copyWith(
                                            color: u.isActive ? NeoColors.emerald : NeoColors.error,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    u.email,
                                    style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                                  ),
                                  trailing: Wrap(
                                    spacing: 8,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      // Role switch
                                      DropdownButton<String>(
                                        value: isAdminUser ? 'Admin' : 'User',
                                        underline: const SizedBox(),
                                        style: NeoTypography.labelSm.copyWith(color: NeoColors.secondary),
                                        items: [
                                          DropdownMenuItem(value: 'User', child: Text(l10n.adminUsersRoleUser)),
                                          DropdownMenuItem(value: 'Admin', child: Text(l10n.adminUsersRoleAdmin)),
                                        ],
                                        onChanged: isCurrent
                                            ? null
                                            : (newRole) async {
                                                if (newRole == null) return;
                                                final repo = ref.read(settingsRepositoryProvider);
                                                await repo.changeRole(u.id, newRole);
                                                ref.invalidate(adminUsersListProvider);
                                              },
                                      ),
                                      // Active toggle
                                      if (!isCurrent)
                                        TextButton(
                                          onPressed: () async {
                                            final repo = ref.read(settingsRepositoryProvider);
                                            if (u.isActive) {
                                              await repo.deactivateUser(u.id);
                                            } else {
                                              await repo.activateUser(u.id);
                                            }
                                            ref.invalidate(adminUsersListProvider);
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: u.isActive ? NeoColors.error : NeoColors.emerald,
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                          child: Text(u.isActive ? l10n.adminUsersDeactivate : l10n.adminUsersActivate),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: NeoSpacing.spaceLg),

                  // 6. Administration — Étiquettes (CRUD réservé aux admins)
                  Consumer(
                    builder: (context, ref, _) {
                      final labelsAsync = ref.watch(labelsListProvider);

                      return _buildCardSection(
                        title: l10n.labelTitle,
                        subtitle: l10n.labelCount(labelsAsync.value?.length ?? 0),
                        child: labelsAsync.when(
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          error: (e, _) => Text(
                            e.toString(),
                            style: NeoTypography.bodySm
                                .copyWith(color: NeoColors.error),
                          ),
                          data: (labels) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (labels.isEmpty) ...[
                                  Text(
                                    l10n.labelEmpty,
                                    style: NeoTypography.bodySm
                                        .copyWith(color: NeoColors.muted),
                                  ),
                                  const SizedBox(height: NeoSpacing.spaceSm),
                                  NeoButton(
                                    label: l10n.labelCreateFirst,
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: () =>
                                        LabelEditModal.show(context, onSaved: (_) {}),
                                  ),
                                ] else ...[
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: labels.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(
                                      height: 1,
                                      color: NeoColors.surfaceContainerHigh,
                                    ),
                                    itemBuilder: (context, index) {
                                      final label = labels[index];
                                      final color = parseLabelColor(label.color);
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        title: Text(
                                          label.name,
                                          style: NeoTypography.labelMd,
                                        ),
                                        trailing: Wrap(
                                          spacing: 4,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 18,
                                                color: NeoColors.muted,
                                              ),
                                              tooltip: l10n.edit,
                                              onPressed: () => LabelEditModal.show(
                                                context,
                                                existing: label,
                                                onSaved: (_) {},
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 18,
                                                color: NeoColors.error,
                                              ),
                                              tooltip: l10n.delete,
                                              onPressed: () async {
                                                final confirmed = await showDialog<bool>(
                                                  context: context,
                                                  builder: (dialogContext) =>
                                                      AlertDialog(
                                                    backgroundColor:
                                                        NeoColors
                                                            .surfaceContainerLowest,
                                                    title: Text(
                                                      l10n.labelDeleteTitle,
                                                      style:
                                                          NeoTypography.headlineSm,
                                                    ),
                                                    content: Text(
                                                      l10n.labelDeleteConfirm(
                                                        label.name,
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    dialogContext)
                                                                .pop(false),
                                                        child: Text(l10n.cancel),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    dialogContext)
                                                                .pop(true),
                                                        child: Text(l10n.delete),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirmed != true) return;
                                                final repo = ref
                                                    .read(labelRepositoryProvider);
                                                await repo.deleteLabel(label.id);
                                                ref.invalidate(labelsListProvider);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: NeoSpacing.spaceSm),
                                  NeoButton(
                                    label: l10n.labelCreateTitle,
                                    variant: NeoButtonVariant.secondary,
                                    isDense: true,
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: () =>
                                        LabelEditModal.show(context, onSaved: (_) {}),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: NeoSpacing.spaceXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(NeoSpacing.spaceLg),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: NeoTypography.headlineSm),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
          ),
          const SizedBox(height: NeoSpacing.spaceMd),
          child,
        ],
      ),
    );
  }
}
