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
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/auth/presentation/homelab_server_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isInvitationMode = false;
  final _invitationTokenController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _invitationTokenController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    await ref.read(authNotifierProvider.notifier).login(email, password);
  }

  Future<void> _submitInvitationRegister() async {
    final token = _invitationTokenController.text.trim();
    final email = _emailController.text.trim();
    final name = _displayNameController.text.trim();
    final password = _passwordController.text;

    if (token.isEmpty || email.isEmpty || name.isEmpty || password.isEmpty) return;

    await ref.read(authNotifierProvider.notifier).registerWithInvitation(
          token: token,
          email: email,
          displayName: name,
          password: password,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;
    final l10n = context.l10n;
    final error = switch (authState) {
      AuthUnauthenticated(:final error) => error,
      AuthUnconfiguredServer(:final error) => error,
      _ => null,
    };
    final errorMessage = error == null
        ? null
        : error is AppFailure
            ? error.type == AppFailureType.unauthorized
                ? l10n.authErrorInvalid
                : localizedFailureMessage(l10n, error)
            : error.toString();

    return Scaffold(
      backgroundColor: NeoColors.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NeoSpacing.spaceLg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
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
                Text(
                  _isInvitationMode ? l10n.authJoinTeam : l10n.authLoginTitle,
                  style: NeoTypography.headlineLg,
                ),
                const SizedBox(height: NeoSpacing.spaceXs),
                Text(
                  _isInvitationMode
                      ? l10n.authInvitationSubtitle
                      : l10n.authLoginTagline,
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
                      if (_isInvitationMode) ...[
                        NeoTextField(
                          controller: _invitationTokenController,
                          labelText: l10n.authInvitationTokenLabel.toUpperCase(),
                          hintText: l10n.authInvitationTokenHint,
                          autofocus: true,
                        ),
                        const SizedBox(height: NeoSpacing.spaceMd),
                        NeoTextField(
                          controller: _displayNameController,
                          labelText: l10n.settingsDisplayName.toUpperCase(),
                          hintText: l10n.authDisplayNameHint,
                        ),
                        const SizedBox(height: NeoSpacing.spaceMd),
                      ],
                      NeoTextField(
                        controller: _emailController,
                        labelText: l10n.authEmail.toUpperCase(),
                        hintText: l10n.authEmailHint,
                        keyboardType: TextInputType.emailAddress,
                        autofocus: !_isInvitationMode,
                      ),
                      const SizedBox(height: NeoSpacing.spaceMd),
                      NeoTextField(
                        controller: _passwordController,
                        labelText: l10n.authPassword.toUpperCase(),
                        hintText: '••••••••••••',
                        obscureText: true,
                        onSubmitted: (_) => _isInvitationMode ? _submitInvitationRegister() : _submitLogin(),
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
                        label: _isInvitationMode ? l10n.authValidateInvitation : l10n.authSubmit,
                        isLoading: isLoading,
                        onPressed: _isInvitationMode ? _submitInvitationRegister : _submitLogin,
                      ),
                      const SizedBox(height: NeoSpacing.spaceMd),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isInvitationMode = !_isInvitationMode;
                          });
                        },
                        child: Text(
                          _isInvitationMode
                              ? l10n.authHaveAccount
                              : l10n.authReceivedInvitation,
                          style: NeoTypography.bodySm.copyWith(
                            color: NeoColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
