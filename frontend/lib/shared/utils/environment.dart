import 'environment_stub.dart'
    if (dart.library.io) 'environment_io.dart';

bool? _isTestEnvironmentOverride;

void setTestEnvironmentOverride(bool? override) {
  _isTestEnvironmentOverride = override;
}

bool isTestEnvironment() => _isTestEnvironmentOverride ?? checkIsTestEnvironment();

