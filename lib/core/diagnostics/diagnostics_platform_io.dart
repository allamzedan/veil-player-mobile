import 'dart:io';

String diagnosticsDartSdkVersion() {
  final version = Platform.version;
  final space = version.indexOf(' ');
  return space == -1 ? version : version.substring(0, space);
}
