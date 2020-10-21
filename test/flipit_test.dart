import 'package:flutter_test/flutter_test.dart';

import 'package:flipit/flipit.dart';

void main() {
  test('adds one to input values', () {
    final _flipit = FlipitListView(
      widgets: [],
      itemDimension: 2000,
    );
    expect(() => _flipit == null, throwsNoSuchMethodError);
  });
}
