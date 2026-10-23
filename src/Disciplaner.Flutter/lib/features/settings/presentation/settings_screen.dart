import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/collaboration_models.dart';
import 'package:disciplaner_flutter/core/shortcuts/app_shortcuts.dart';
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/settings/presentation/settings_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
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
  String? _profileMessage;
  bool _profileSuccess = true;

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
      _profileMessage = null;
    });

    try {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.updateDisplayName(newName);
      await ref.read(authNotifierProvider.notifier).updateDisplayNameLocal(newName);
      if (mounted) {
        setState(() {
          _profileSuccess = true;
          _profileMessage = 'Nom d\'affichage mis à jour avec succès.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _profileSuccess = false;
          _profileMessage = 'Erreur lors de la mise à jour : $e';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'URL du serveur Homelab mise à jour' : 'Impossible de contacter le serveur',
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir une adresse email valide.'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation générée pour $email !'),
            backgroundColor: NeoColors.emerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création de l\'invitation : $e'),
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
                      'Paramètres',
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
                          'Administrateur',
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
                  'Préférences utilisateur, configuration Homelab et gestion des accès',
                  style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                ),
                const SizedBox(height: NeoSpacing.spaceXl),

                // 0. Affichage & Mise à l'échelle (UI Scaling)
                _buildCardSection(
                  title: 'Affichage & Mise à l\'échelle (UI Scaling)',
                  subtitle: 'Adaptez la taille des polices et des éléments visuels à la résolution de votre écran',
                  child: Consumer(
                    builder: (context, ref, _) {
                      final currentScale = ref.watch(uiScaleProvider);
                      final currentPercent = (currentScale * 100).round();
                      final presets = [
                        (0.9, 'Compact (90%)'),
                        (1.0, 'Standard (100%)'),
                        (1.1, 'Confort (110%)'),
                        (1.2, 'Grand écran (120%)'),
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
                                      'Facteur de mise à l\'échelle personnalisé',
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
                                      tooltip: 'Réduire (-5%)',
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
                                      tooltip: 'Augmenter (+5%)',
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
                                      child: const Text('Appliquer'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ref.read(uiScaleProvider.notifier).reset();
                                        _customScaleController.text = '100';
                                      },
                                      child: const Text('Réinitialiser (100%)'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: NeoSpacing.spaceSm),
                          Text(
                            'Astuce : vous pouvez saisir n\'importe quel pourcentage entre 50% et 200%, ou ajuster le facteur depuis la barre supérieure.',
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
                  title: 'Profil & Compte',
                  subtitle: 'Gérez vos informations de compte Disciplan',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          UserAvatar(
                            name: session?.displayName ?? 'Utilisateur',
                            size: 48,
                          ),
                          const SizedBox(width: NeoSpacing.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session?.displayName ?? 'Utilisateur',
                                  style: NeoTypography.headlineSm,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  session?.email ?? 'Non connecté',
                                  style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: NeoSpacing.spaceLg),
                      Text(
                        'Nom d\'affichage',
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
                                hintText: 'Votre nom d\'affichage...',
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
                                : const Text('Enregistrer'),
                          ),
                        ],
                      ),
                      if (_profileMessage != null) ...[
                        const SizedBox(height: NeoSpacing.spaceSm),
                        Text(
                          _profileMessage!,
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
                                  'Session active',
                                  style: NeoTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Déconnecte ce poste de votre instance Disciplan',
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
                              'Se déconnecter',
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
                  title: 'Serveur Homelab',
                  subtitle: 'Adresse de votre instance Disciplan sur le réseau local ou distant',
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
                            child: const Text('Appliquer'),
                          ),
                        ],
                      ),
                      const SizedBox(height: NeoSpacing.spaceSm),
                      Text(
                        'Les requêtes HTTP et l\'abonnement iCal s\'appuient sur cette URL de base.',
                        style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NeoSpacing.spaceLg),

                // 3. Vues Sauvegardées
                _buildCardSection(
                  title: 'Vues Sauvegardées',
                  subtitle: 'Gérez vos filtres et vues personnalisées épinglées à la barre latérale',
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
                            'Impossible de charger les vues : $err',
                            style: NeoTypography.bodySm.copyWith(color: NeoColors.error),
                          ),
                        ),
                        data: (views) {
                          if (views.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: NeoSpacing.spaceMd),
                              child: Text(
                                'Aucune vue sauvegardée pour le moment. Vous pouvez en créer depuis la Vue Liste.',
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
                                  'Projet: ${view.projectId ?? "Tous"} • Type: ${view.type?.name ?? "Tous"}',
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
                                      tooltip: view.isVisibleOnHome ? 'Détacher' : 'Épingler',
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
                                      tooltip: 'Supprimer',
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

                // 4. Administration (si rôle Admin)
                if (isAdmin) ...[
                  const SizedBox(height: NeoSpacing.spaceLg),
                  _buildCardSection(
                    title: 'Administration — Invitations (7 jours)',
                    subtitle: 'Générez des liens d\'invitation à usage unique pour intégrer de nouveaux membres',
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
                                  hintText: 'adresse@entreprise.com',
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
                              label: const Text('Générer un lien (7j)'),
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
                                  tooltip: 'Copier le lien',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: _lastCreatedInviteUrl!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Lien d\'invitation copié dans le presse-papiers'),
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
                          'Invitations en attente ou récentes',
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
                                'Erreur chargement invitations: $e',
                                style: NeoTypography.bodySm.copyWith(color: NeoColors.error),
                              ),
                              data: (invites) {
                                if (invites.isEmpty) {
                                  return Text(
                                    'Aucune invitation en cours.',
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
                                        'Expire le ${inv.expiresAt.day}/${inv.expiresAt.month}/${inv.expiresAt.year} • ${inv.isUsed ? "Déjà utilisée" : (isExpired ? "Expirée" : "Valide")}',
                                        style: NeoTypography.bodySm.copyWith(
                                          color: inv.isUsed
                                              ? NeoColors.muted
                                              : (isExpired ? NeoColors.error : NeoColors.emerald),
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.copy, size: 16),
                                        tooltip: 'Copier le jeton',
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: inv.token));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Jeton d\'invitation copié'),
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
                    title: 'Administration — Gestion des Comptes',
                    subtitle: 'Activer, désactiver ou changer les rôles des utilisateurs de l\'instance',
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
                            'Erreur chargement utilisateurs: $e',
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
                                          '(vous)',
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
                                          u.isActive ? 'Actif' : 'Inactif',
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
                                        items: const [
                                          DropdownMenuItem(value: 'User', child: Text('User')),
                                          DropdownMenuItem(value: 'Admin', child: Text('Admin')),
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
                                          child: Text(u.isActive ? 'Désactiver' : 'Activer'),
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
