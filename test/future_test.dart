// A class for testing futures

import 'package:flutter_test/flutter_test.dart';

main() {
  test('Future', () async {
    Future<int> x() => Future.error("Random error");
    Future<int> y() => Future.value(1);

    var first = await x().catchError((_) => null);
    var second = await y();

    expect(first, null);
    expect(second, 1);
  });
}
