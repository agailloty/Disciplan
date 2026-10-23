import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
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
  String? _statusMessage;
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
      _statusMessage = null;
    });

    final success = await ref
        .read(authNotifierProvider.notifier)
        .updateServerUrl(_controller.text);

    if (mounted) {
      setState(() {
        _isTesting = false;
        _isSuccess = success;
        _statusMessage = success
            ? 'Connexion établie avec succès.'
            : 'Échec de connexion au serveur Homelab.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'SERVEUR HOMELAB',
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
                label: 'Tester',
                isDense: true,
                variant: NeoButtonVariant.secondary,
                isLoading: _isTesting,
                onPressed: _testAndSave,
              ),
            ],
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: NeoSpacing.spaceXs),
            Text(
              _statusMessage!,
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
