import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/neo_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? name;
  final String? initials;
  final double size;
  final bool? isOnline;
  final Color? backgroundColor;
  final Uint8List? imageBytes;

  const UserAvatar({
    super.key,
    this.name,
    this.initials,
    this.size = 22,
    this.isOnline,
    this.backgroundColor,
    this.imageBytes,
  });

  String get _computedInitials {
    if (initials != null && initials!.isNotEmpty) {
      return initials!.toUpperCase();
    }
    if (name == null || name!.trim().isEmpty) {
      return '?';
    }
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _buildInitialsText() {
    return Text(
      _computedInitials,
      style: GoogleFonts.jetBrainsMono(
        fontSize: size * 0.42,
        fontWeight: FontWeight.w600,
        color: NeoColors.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? NeoColors.surfaceContainerHigh,
        shape: BoxShape.circle,
        border: Border.all(color: NeoColors.borderWhisper, width: 1),
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: (imageBytes != null && imageBytes!.isNotEmpty)
          ? Image.memory(
              imageBytes!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildInitialsText(),
            )
          : _buildInitialsText(),
    );

    if (isOnline == null) {
      return avatar;
    }

    final dotSize = (size * 0.32).clamp(6.0, 10.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: isOnline! ? NeoColors.emerald : NeoColors.statusSlate,
              shape: BoxShape.circle,
              border: Border.all(
                color: NeoColors.surfaceContainerLowest,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
