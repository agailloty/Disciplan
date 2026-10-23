import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class UiScaleNotifier extends Notifier<double> {
  static const double minScale = 0.50;
  static const double maxScale = 2.00;

  @override
  double build() => 1.0;
  void setScale(double scale) => state = scale.clamp(minScale, maxScale);
  void increase() => setScale(state + 0.05);
  void decrease() => setScale(state - 0.05);
  void reset() => state = 1.0;
}

final commandPaletteOpenProvider =
    NotifierProvider<CommandPaletteOpenNotifier, bool>(CommandPaletteOpenNotifier.new);

final quickCreateTicketOpenProvider =
    NotifierProvider<QuickCreateTicketOpenNotifier, bool>(QuickCreateTicketOpenNotifier.new);

final uiScaleProvider =
    NotifierProvider<UiScaleNotifier, double>(UiScaleNotifier.new);

// Intents
class OpenCommandPaletteIntent extends Intent {
  const OpenCommandPaletteIntent();
}

class QuickCreateTicketIntent extends Intent {
  const QuickCreateTicketIntent();
}

class AppShortcutsWrapper extends ConsumerWidget {
  final Widget child;

  const AppShortcutsWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiScale = ref.watch(uiScaleProvider);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(uiScale),
      ),
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
              const OpenCommandPaletteIntent(),
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK):
              const OpenCommandPaletteIntent(),
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
      ),
    );
  }
}
