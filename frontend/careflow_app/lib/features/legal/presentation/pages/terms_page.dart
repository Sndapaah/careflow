import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';

import '../../../../core/widgets/app_top_bar.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const AppTopBar(title: 'Terms of Use'),
            Expanded(
              child: PdfPreview(
                build: (_) => rootBundle
                    .load('assets/legal/careflow_terms_and_conditions.pdf')
                    .then((data) => data.buffer.asUint8List()),
                canChangeOrientation: false,
                canChangePageFormat: false,
                allowSharing: true,
                allowPrinting: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}