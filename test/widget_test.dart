import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mando_sof_webview/main.dart';

void main() {
  test('MandoSofApp is a StatelessWidget', () {
    const app = MandoSofApp();
    expect(app, isA<StatelessWidget>());
  });
}
