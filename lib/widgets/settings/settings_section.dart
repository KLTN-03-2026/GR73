import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentLocale = localeProvider.locale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(AppLocalizations.of(context)!.language),
          leading: const Icon(Icons.language),
        ),
        RadioListTile<String>(
          title: Text(AppLocalizations.of(context)!.vietnamese),
          value: 'vi',
          // ignore: deprecated_member_use
          groupValue: currentLocale.languageCode,
          // ignore: deprecated_member_use
          onChanged: (value) {
            if (value != null) localeProvider.setLocale(Locale(value));
          },
          activeColor: Theme.of(context).primaryColor,
        ),
        RadioListTile<String>(
          title: Text(AppLocalizations.of(context)!.english),
          value: 'en',
          // ignore: deprecated_member_use
          groupValue: currentLocale.languageCode,
          // ignore: deprecated_member_use
          onChanged: (value) {
            if (value != null) localeProvider.setLocale(Locale(value));
          },
          activeColor: Theme.of(context).primaryColor,
        ),
        const Divider(height: 24),
        ListTile(
          title: Text(AppLocalizations.of(context)!.theme),
          leading: const Icon(Icons.color_lens_outlined),
        ),
        RadioListTile<ThemeMode>(
          title: Text(AppLocalizations.of(context)!.themeLight),
          value: ThemeMode.light,
          groupValue: themeProvider.themeMode,
          onChanged: (value) {
            if (value != null) themeProvider.setThemeMode(value);
          },
          activeColor: Theme.of(context).primaryColor,
        ),
        RadioListTile<ThemeMode>(
          title: Text(AppLocalizations.of(context)!.themeDark),
          value: ThemeMode.dark,
          groupValue: themeProvider.themeMode,
          onChanged: (value) {
            if (value != null) themeProvider.setThemeMode(value);
          },
          activeColor: Theme.of(context).primaryColor,
        ),
        RadioListTile<ThemeMode>(
          title: Text(AppLocalizations.of(context)!.themeSystem),
          value: ThemeMode.system,
          groupValue: themeProvider.themeMode,
          onChanged: (value) {
            if (value != null) themeProvider.setThemeMode(value);
          },
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
}
