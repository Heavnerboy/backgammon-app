import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import '../state/language_provider.dart';
import '../l10n/generated/app_localizations.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    final langProvider = context.watch<LanguageProvider>();
    final currentCode = langProvider.locale?.languageCode ?? 'system';

    final loc = AppLocalizations.of(context)!;

    return Drawer(
      elevation: 16,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ListTile(
              leading: const Icon(Icons.tune),
              title: Text(
                loc.settings,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(loc.language,
                  style: Theme.of(context).textTheme.labelLarge),
            ),
            RadioListTile<String>(
              value: 'system',
              groupValue: currentCode,
              title: Text(loc.systemDefault),
              onChanged: (_) {
                langProvider.setLocale(null);
                Navigator.of(context).maybePop();
              },
            ),
            RadioListTile<String>(
              value: 'de',
              groupValue: currentCode,
              title: Text(loc.german),
              onChanged: (_) {
                langProvider.setLocale(const Locale('de'));
                Navigator.of(context).maybePop();
              },
            ),
            RadioListTile<String>(
              value: 'en',
              groupValue: currentCode,
              title: Text(loc.english),
              onChanged: (_) {
                langProvider.setLocale(const Locale('en'));
                Navigator.of(context).maybePop();
              },
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(loc.appearance,
                  style: Theme.of(context).textTheme.labelLarge),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: Text(loc.darkMode),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              trailing: _ThemeModeToggle(
                isDark: isDark,
                onToggle: () => context.read<ThemeProvider>().toggleTheme(),
              ),
              onTap: () => context.read<ThemeProvider>().toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeToggle extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggle;
  const _ThemeModeToggle({
    required this.isDark,
    required this.onToggle,
  });

  @override
  State<_ThemeModeToggle> createState() => _ThemeModeToggleState();
}

class _ThemeModeToggleState extends State<_ThemeModeToggle>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bool isDark = widget.isDark;

    const double width = 64;
    const double height = 34;
    const double padding = 4;
    const double knob = height - padding * 2;

    final Color surfaceHighest =
        (Theme.of(context).colorScheme).surfaceVariant;

    return Semantics(
      label: AppLocalizations.of(context)!.darkMode,
      value: isDark
          ? 'Darkmode aktiv'
          : 'Lightmode aktiv',
      button: true,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: width,
          height: height,
          padding: const EdgeInsets.all(padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      scheme.primaryContainer.withOpacity(0.25),
                      scheme.primary.withOpacity(0.35),
                    ]
                  : [
                      scheme.tertiaryContainer.withOpacity(0.5),
                      surfaceHighest.withOpacity(0.9),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? scheme.primary.withOpacity(0.4)
                  : scheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    size: 16,
                    color: isDark
                        ? scheme.onSurface.withOpacity(0.35)
                        : scheme.onSurface.withOpacity(0.9),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.nights_stay_rounded,
                    size: 16,
                    color: isDark
                        ? scheme.onSurface.withOpacity(0.9)
                        : scheme.onSurface.withOpacity(0.35),
                  ),
                ),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment:
                    isDark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: knob,
                  height: knob,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(knob / 2),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                        color: Colors.black.withOpacity(0.25),
                      ),
                    ],
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      key: ValueKey(isDark),
                      size: 16,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}