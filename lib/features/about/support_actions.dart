// lib/features/about/support_actions.dart
//
// Launch helpers for the About screen's support tiles (rate, share,
// feedback, privacy policy). Each tries the preferred target first and
// falls back where it makes sense; a SnackBar is shown if nothing opens.

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'app_links.dart';

Future<bool> _tryLaunch(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

Future<void> _launchFirst(BuildContext context, List<Uri> uris) async {
  final messenger = ScaffoldMessenger.of(context);
  final failedText = context.l10n.linkOpenFailed;
  for (final uri in uris) {
    if (await _tryLaunch(uri)) return;
  }
  messenger.showSnackBar(SnackBar(content: Text(failedText)));
}

Future<void> rateApp(BuildContext context) => _launchFirst(context, [
      Uri.parse(AppLinks.marketUri),
      Uri.parse(AppLinks.playStoreUrl),
    ]);

Future<void> shareApp(BuildContext context) async {
  await SharePlus.instance.share(
    ShareParams(text: context.l10n.shareAppMessage(AppLinks.playStoreUrl)),
  );
}

/// Opens a WhatsApp chat; falls back to the SMS app if WhatsApp isn't installed.
Future<void> openFeedbackChat(BuildContext context) => _launchFirst(context, [
      Uri.parse('whatsapp://send?phone=${AppLinks.whatsappNumber}'),
      Uri(scheme: 'sms', path: AppLinks.smsNumber),
    ]);

Future<void> openPrivacyPolicy(BuildContext context) =>
    _launchFirst(context, [Uri.parse(AppLinks.privacyPolicyUrl)]);

Future<void> openDeveloperEmail(BuildContext context) => _launchFirst(context, [
      Uri(scheme: 'mailto', path: AppLinks.developerEmail),
    ]);

Future<void> openDeveloperWebsite(BuildContext context) =>
    _launchFirst(context, [Uri.parse(AppLinks.developerWebsite)]);
