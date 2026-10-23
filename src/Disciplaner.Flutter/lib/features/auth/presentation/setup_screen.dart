import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
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
  String? _errorMessage;

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
      setState(() => _errorMessage = 'Veuillez remplir tous les champs.');
      return;
    }

    if (password.length < 8) {
      setState(() => _errorMessage = 'Le mot de passe doit comporter au moins 8 caractères.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Text('Premier Démarrage', style: NeoTypography.headlineLg),
                const SizedBox(height: NeoSpacing.spaceXs),
                Text(
                  'Initialisez votre instance Homelab en créant le compte administrateur racine.',
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
                        labelText: 'NOM D\'AFFICHAGE',
                        hintText: 'ex. Alexandre Gailloty',
                        autofocus: true,
                      ),
                      const SizedBox(height: NeoSpacing.spaceMd),
                      NeoTextField(
                        controller: _emailController,
                        labelText: 'ADRESSE E-MAIL',
                        hintText: 'admin@disciplan.local',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: NeoSpacing.spaceMd),
                      NeoTextField(
                        controller: _passwordController,
                        labelText: 'MOT DE PASSE (MIN. 8 CARACTÈRES)',
                        hintText: '••••••••••••',
                        obscureText: true,
                        onSubmitted: (_) => _submit(),
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
                      NeoButton(
                        label: 'Créer le compte Administrateur',
                        isLoading: _isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NeoSpacing.spaceLg),
                const HomelabServerCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
