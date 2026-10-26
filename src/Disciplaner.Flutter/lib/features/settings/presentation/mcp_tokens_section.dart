import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/features/settings/data/mcp_token_models.dart';
import 'package:disciplaner_flutter/features/settings/presentation/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Settings section managing the current user's MCP personal access tokens:
/// list, creation (raw token shown exactly once, with copy), revocation.
class McpTokensSection extends ConsumerStatefulWidget {
  const McpTokensSection({super.key});

  @override
  ConsumerState<McpTokensSection> createState() => _McpTokensSectionState();
}

class _McpTokensSectionState extends ConsumerState<McpTokensSection> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokensAsync = ref.watch(mcpTokensListProvider);

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
          Text(l10n.settingsMcpTokensTitle, style: NeoTypography.headlineSm),
          const SizedBox(height: 2),
          Text(
            l10n.settingsMcpTokensSubtitle,
            style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
          ),
          const SizedBox(height: NeoSpacing.spaceMd),
          tokensAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => Text(
              l10n.settingsUsersError(e.toString()),
              style: NeoTypography.bodySm.copyWith(color: NeoColors.error),
            ),
            data: (tokens) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tokens.isEmpty)
                  Text(
                    l10n.settingsMcpTokensEmpty,
                    style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tokens.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: NeoColors.surfaceContainerHigh,
                    ),
                    itemBuilder: (context, index) =>
                        _buildTokenRow(context, tokens[index]),
                  ),
                const SizedBox(height: NeoSpacing.spaceSm),
                NeoButton(
                  label: l10n.settingsMcpTokensCreate,
                  variant: NeoButtonVariant.secondary,
                  isDense: true,
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: _showCreateDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenRow(BuildContext context, McpTokenDto token) {
    final l10n = context.l10n;
    final dateFmt =
        '${token.createdAt.day.toString().padLeft(2, '0')}/${token.createdAt.month.toString().padLeft(2, '0')}/${token.createdAt.year}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Text(token.name, style: NeoTypography.labelMd),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: token.isRevoked
                  ? NeoColors.error.withValues(alpha: 0.1)
                  : NeoColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              token.isRevoked
                  ? l10n.settingsMcpTokenRevoked
                  : (token.canWrite
                      ? l10n.settingsMcpTokensScopeReadWrite
                      : l10n.settingsMcpTokensScopeRead),
              style: NeoTypography.labelSm.copyWith(
                color: token.isRevoked ? NeoColors.error : NeoColors.primary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        token.lastUsedAt == null
            ? l10n.settingsMcpTokenNeverUsed(dateFmt)
            : l10n.settingsMcpTokenLastUsed(
                dateFmt,
                '${token.lastUsedAt!.day.toString().padLeft(2, '0')}/${token.lastUsedAt!.month.toString().padLeft(2, '0')}/${token.lastUsedAt!.year}'),
        style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
      ),
      trailing: token.isRevoked
          ? null
          : TextButton(
              onPressed: () => _revokeToken(token),
              style: TextButton.styleFrom(
                foregroundColor: NeoColors.error,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(l10n.settingsMcpTokenRevoke),
            ),
    );
  }

  Future<void> _showCreateDialog() async {
    final l10n = context.l10n;
    final nameController = TextEditingController();
    var scopes = 'read';

    final created = await showDialog<CreatedMcpToken>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: NeoColors.surfaceContainerLow,
          title: Text(l10n.settingsMcpTokensCreateTitle, style: NeoTypography.headlineSm),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settingsMcpTokensNameLabel,
                    style: NeoTypography.labelSm.copyWith(color: NeoColors.muted)),
                const SizedBox(height: NeoSpacing.spaceXs),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.settingsMcpTokensNameHint,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: NeoSpacing.spaceMd),
                Text(l10n.settingsMcpTokensScopeLabel,
                    style: NeoTypography.labelSm.copyWith(color: NeoColors.muted)),
                const SizedBox(height: NeoSpacing.spaceXs),
                RadioGroup<String>(
                  groupValue: scopes,
                  onChanged: (v) => setDialogState(() => scopes = v!),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        value: 'read',
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.settingsMcpTokensScopeRead,
                            style: NeoTypography.labelSm),
                      ),
                      RadioListTile<String>(
                        value: 'read+write',
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.settingsMcpTokensScopeReadWrite,
                            style: NeoTypography.labelSm),
                        subtitle: Text(
                          l10n.settingsMcpTokensScopeHelp,
                          style: NeoTypography.bodySm.copyWith(color: NeoColors.muted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: NeoColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final navigator = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(dialogContext);
                try {
                  final repo = ref.read(settingsRepositoryProvider);
                  final token = await repo.createMcpToken(name: name, scopes: scopes);
                  navigator.pop(token);
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.settingsUsersError(e.toString()),
                        style: NeoTypography.bodySm.copyWith(color: Colors.white),
                      ),
                      backgroundColor: NeoColors.error,
                    ),
                  );
                }
              },
              child: Text(l10n.settingsMcpTokensCreate),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    ref.invalidate(mcpTokensListProvider);
    if (created != null && mounted) await _showCreatedTokenDialog(created);
  }

  /// The raw token is shown exactly once, with a copy action and a warning.
  Future<void> _showCreatedTokenDialog(CreatedMcpToken token) async {
    final l10n = context.l10n;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: NeoColors.surfaceContainerLow,
        title: Text(l10n.settingsMcpTokenCreatedTitle, style: NeoTypography.headlineSm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsMcpTokenCreatedWarning,
              style: NeoTypography.bodySm.copyWith(color: NeoColors.error),
            ),
            const SizedBox(height: NeoSpacing.spaceMd),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(NeoSpacing.spaceSm),
              decoration: BoxDecoration(
                color: NeoColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: NeoColors.borderWhisper),
              ),
              child: SelectableText(
                token.token,
                style: GoogleFonts.jetBrainsMono(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: token.token));
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.settingsMcpTokenCopied,
                      style: NeoTypography.bodySm.copyWith(color: Colors.white),
                    ),
                    backgroundColor: NeoColors.primary,
                  ),
                );
              }
            },
            child: Text(l10n.settingsMcpTokenCopy),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: NeoColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.settingsMcpTokenDone),
          ),
        ],
      ),
    );
  }

  Future<void> _revokeToken(McpTokenDto token) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: NeoColors.surfaceContainerLow,
        title: Text(l10n.settingsMcpTokenRevokeConfirmTitle, style: NeoTypography.headlineSm),
        content: Text(
          l10n.settingsMcpTokenRevokeConfirm(token.name),
          style: NeoTypography.bodySm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: NeoColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.settingsMcpTokenRevoke),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final repo = ref.read(settingsRepositoryProvider);
    await repo.revokeMcpToken(token.id);
    ref.invalidate(mcpTokensListProvider);
  }
}
