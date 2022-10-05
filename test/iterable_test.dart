import 'package:flutter_test/flutter_test.dart';
import 'package:iterable/iterable_platform_interface.dart';
import 'package:iterable/iterable_method_channel.dart';


void main() {
  final IterablePlatform initialPlatform = IterablePlatform.instance;

  test('$MethodChannelIterable is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIterable>());
  });

  test('getPlatformVersion', () async {

  });
}
