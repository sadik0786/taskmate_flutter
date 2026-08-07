// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
  final base64Data = base64Encode(bytes);
  final uri = 'data:application/octet-stream;base64,$base64Data';
  html.AnchorElement(href: uri)
    ..setAttribute('download', fileName)
    ..click();
}
