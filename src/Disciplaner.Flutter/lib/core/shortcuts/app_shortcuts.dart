import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SidebarCollapsedNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void set(bool value) => state = value;
}

class CommandPaletteOpenNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void set(bool value) => state = value;
}

class QuickCreateTicketOpenNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final sidebarCollapsedProvider =
    NotifierProvider<SidebarCollapsedNotifier, bool>(SidebarCollapsedNotifier.new);

final commandPaletteOpenProvider =
    NotifierProvider<CommandPaletteOpenNotifier, bool>(CommandPaletteOpenNotifier.new);

final quickCreateTicketOpenProvider =
    NotifierProvider<QuickCreateTicketOpenNotifier, bool>(QuickCreateTicketOpenNotifier.new);

// Intents
class OpenCommandPaletteIntent extends Intent {
  const OpenCommandPaletteIntent();
}

class ToggleSidebarIntent extends Intent {
  const ToggleSidebarIntent();
}

class QuickCreateTicketIntent extends Intent {
  const QuickCreateTicketIntent();
}

class AppShortcutsWrapper extends ConsumerWidget {
  final Widget child;

  const AppShortcutsWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
            const OpenCommandPaletteIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK):
            const OpenCommandPaletteIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyB):
            const ToggleSidebarIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyB):
            const ToggleSidebarIntent(),
        const SingleActivator(LogicalKeyboardKey.keyC):
            const QuickCreateTicketIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          OpenCommandPaletteIntent: CallbackAction<OpenCommandPaletteIntent>(
            onInvoke: (intent) {
              ref.read(commandPaletteOpenProvider.notifier).toggle();
              return null;
            },
          ),
          ToggleSidebarIntent: CallbackAction<ToggleSidebarIntent>(
            onInvoke: (intent) {
              ref.read(sidebarCollapsedProvider.notifier).toggle();
              return null;
            },
          ),
          QuickCreateTicketIntent: CallbackAction<QuickCreateTicketIntent>(
            onInvoke: (intent) {
              final primaryFocus = FocusManager.instance.primaryFocus;
              if (primaryFocus != null &&
                  primaryFocus.context != null &&
                  primaryFocus.context!.findAncestorWidgetOfExactType<EditableText>() != null) {
                return null;
              }
              ref.read(quickCreateTicketOpenProvider.notifier).toggle();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}
