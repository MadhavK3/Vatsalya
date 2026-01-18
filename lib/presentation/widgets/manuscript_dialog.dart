import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maternal_infant_care/core/theme/app_theme.dart';

class ManuscriptDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const ManuscriptDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content,
      actions: actions,
    );
  }
}

// Global Help Method
void showManuscriptDialog(BuildContext context, {required String title, required Widget content, List<Widget>? actions}) {
  showDialog(
    context: context,
    builder: (context) => ManuscriptDialog(title: title, content: content, actions: actions),
  );
}
