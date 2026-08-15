import 'package:flutter_js/flutter_js.dart';
void main() {
  final runtime = getJavascriptRuntime();
  runtime.evaluate('function test() { return "hello"; }');
  final res = runtime.evaluate('test()');
  print('Result: ${res.stringResult}');
  print('Is enclosed in quotes? ${res.stringResult.startsWith('"')}');
}
