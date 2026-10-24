import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/errors/app_failure.dart';
import 'package:disciplaner_flutter/core/l10n/failure_l10n.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/neo_card.dart';
import 'package:disciplaner_flutter/core/widgets/neo_text_field.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/homelab_server_card.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  _SetupError? _validationError;
  Object? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      setState(() => _validationError = _SetupError.missingFields);
      return;
    }

    if (password.length < 8) {
      setState(() => _validationError = _SetupError.passwordTooShort);
      return;
    }

    setState(() {
      _isLoading = true;
      _validationError = null;
      _error = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).setupInitialAdmin(
            email: email,
            displayName: name,
            password: password,
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final errorMessage = switch (_validationError) {
      _SetupError.missingFields => l10n.authSetupFillAllFields,
      _SetupError.passwordTooShort => l10n.authSetupPasswordTooShort,
      null => _error == null
          ? null
          : _error is AppFailure
              ? localizedFailureMessage(l10n, _error as AppFailure)
              : _error.toString(),
    };
    return Scaffold(
      backgroundColor: NeoColors.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NeoSpacing.spaceLg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo & Titre
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: NeoColors.primary,
                    borderRadius: NeoSpacing.roundedMd,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'D',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: NeoSpacing.spaceMd),
                Text(l10n.authSetupTitle, style: NeoTypography.headlineLg),
                const SizedBox(height: NeoSpacing.spaceXs),
                Text(
                  l10n.authSetupIntro,
                  textAlign: TextAlign.center,
                  style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                ),
                const SizedBox(height: NeoSpacing.spaceLg),

                // Carte formulaire
                NeoCard(
                  hasOverlayShadow: true,
                  padding: const EdgeInsets.all(NeoSpacing.spaceLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NeoTextField(
                        controller: _nameController,
                        labelText: l10n.settingsDisplayName.toUpperCase(),
                        hintText: l10n.authSetupDisplayNameHint,
                        autofocus: true,
                      ),
                      const SizedBox(height: NeoSpacing.spaceMd),
                      NeoTextField(
                        controller: _emailController,
                        labelText: l10n.authEmail.toUpperCase(),
                        hintText: 'admin@disciplan.local',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: NeoSpacing.spaceMd),
                      NeoTextField(
                        controller: _passwordController,
                        labelText: l10n.authSetupPasswordLabel.toUpperCase(),
                        hintText: '••••••••••••',
                        obscureText: true,
                        onSubmitted: (_) => _submit(),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: NeoSpacing.spaceMd),
                        Container(
                          padding: const EdgeInsets.all(NeoSpacing.spaceSm),
                          decoration: BoxDecoration(
                            color: NeoColors.error.withValues(alpha: 0.08),
                            borderRadius: NeoSpacing.roundedSm,
                            border: Border.all(color: NeoColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            errorMessage,
                            style: NeoTypography.bodySm.copyWith(color: NeoColors.error),
                          ),
                        ),
                      ],
                      const SizedBox(height: NeoSpacing.spaceLg),
                      NeoButton(
                        label: l10n.setupCreateAdmin,
                        isLoading: _isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NeoSpacing.spaceLg),
                // Sur le web, l'application est servie par le conteneur
                // Docker (même origine que l'API) : la saisie de l'URL du
                // serveur reste disponible sur desktop / mobile, ou via la
                // route isolée /setup-server.
                if (!kIsWeb) const HomelabServerCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _SetupError { missingFields, passwordTooShort }
