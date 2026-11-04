import 'environment_stub.dart'
    if (dart.library.io) 'environment_io.dart';

bool isTestEnvironment() => checkIsTestEnvironment();
