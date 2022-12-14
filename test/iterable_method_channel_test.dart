import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iterable/iterable_method_channel.dart';

void main() {
  MethodChannelIterable platform = MethodChannelIterable();
  const MethodChannel channel = MethodChannel('iterable');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
