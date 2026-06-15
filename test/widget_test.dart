import 'package:flutter_test/flutter_test.dart';
import 'package:delievry_app/main.dart';

void main() {
  test('App widget instantiation test', () {
    const app = DelievryApp();
    expect(app, isA<DelievryApp>());
  });
}
