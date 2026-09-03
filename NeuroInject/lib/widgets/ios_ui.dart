import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Shared iOS-native chrome so the app's confirmations and transient messages
/// read as deliberate iOS rather than stock Material defaults (a de-slop move:
/// the default component is the tell).

/// A yes/no confirmation as an iOS alert. Returns true only if confirmed.
Future<bool> showConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) async {
  final ok = await showCupertinoDialog<bool>(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(message),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel),
        ),
        CupertinoDialogAction(
          isDestructiveAction: isDestructive,
          isDefaultAction: !isDestructive,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// A branded transient message — replaces the stock Material SnackBar with a
/// floating, rounded, on-brand toast (kept on ScaffoldMessenger for lifecycle
/// and reduced-motion behaviour).
void showAppSnack(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bg = isError
      ? AppTheme.danger
      : (isDark ? AppTheme.surfaceElevated : const Color(0xFF283039));
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: bg,
      elevation: 0,
      duration: duration,
      action: action,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      content: Text(message,
          style: GoogleFonts.sourceSans3(
              fontSize: 13, color: Colors.white, height: 1.3)),
    ));
}
