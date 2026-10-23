import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/widgets/kbd_chip.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/neo_card.dart';
import 'package:disciplaner_flutter/core/widgets/neo_text_field.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';

class HomelabServerCard extends ConsumerStatefulWidget {
  const HomelabServerCard({super.key});

  @override
  ConsumerState<HomelabServerCard> createState() => _HomelabServerCardState();
}

class _HomelabServerCardState extends ConsumerState<HomelabServerCard> {
  late final TextEditingController _controller;
  bool _isTesting = false;
  bool _hasResult = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(serverConfigStorageProvider);
    _controller = TextEditingController(text: storage.getBaseUrl());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _testAndSave() async {
    setState(() {
      _isTesting = true;
      _hasResult = false;
    });

    final success = await ref
        .read(authNotifierProvider.notifier)
        .updateServerUrl(_controller.text);

    if (mounted) {
      setState(() {
        _isTesting = false;
        _isSuccess = success;
        _hasResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NeoCard(
      backgroundColor: NeoColors.surfaceContainerLow,
      padding: const EdgeInsets.all(NeoSpacing.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isSuccess ? NeoColors.emerald : NeoColors.statusAmber,
                ),
              ),
              const SizedBox(width: NeoSpacing.spaceSm),
              Text(
                l10n.authHomelabServer.toUpperCase(),
                style: NeoTypography.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: NeoColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              const KbdChip(label: 'HTTP/S'),
            ],
          ),
          const SizedBox(height: NeoSpacing.spaceSm),
          Row(
            children: [
              Expanded(
                child: NeoTextField(
                  controller: _controller,
                  hintText: 'http://192.168.1.50:8080',
                  isDense: true,
                ),
              ),
              const SizedBox(width: NeoSpacing.spaceSm),
              NeoButton(
                label: l10n.authServerTest,
                isDense: true,
                variant: NeoButtonVariant.secondary,
                isLoading: _isTesting,
                onPressed: _testAndSave,
              ),
            ],
          ),
          if (_hasResult) ...[
            const SizedBox(height: NeoSpacing.spaceXs),
            Text(
              _isSuccess ? l10n.authServerTestSuccess : l10n.authServerTestFailed,
              style: NeoTypography.labelSm.copyWith(
                color: _isSuccess ? NeoColors.emerald : NeoColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
