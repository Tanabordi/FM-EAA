import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Frontend Security Tests: Auth & Token Isolation', () {
    late FlutterSecureStorage secureStorage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      secureStorage = const FlutterSecureStorage();
    });

    test('Sensitive JWT tokens are securely stored and cleared on logout', () async {
      await secureStorage.write(key: 'jwt_token', value: 'secret_jwt_token_xyz');
      await secureStorage.write(key: 'user_id', value: 'usr_secure_99');
      await secureStorage.write(key: 'user_username', value: 'alice_sec');
      await secureStorage.write(key: 'user_email', value: 'alice@sec.org');

      expect(await secureStorage.read(key: 'jwt_token'), 'secret_jwt_token_xyz');
      expect(await secureStorage.read(key: 'user_id'), 'usr_secure_99');

      final apiClient = ApiClient(customStorage: secureStorage);
      final authRepo = AuthRepository(apiClient: apiClient);

      await authRepo.logout();

      expect(await secureStorage.read(key: 'jwt_token'), isNull);
      expect(await secureStorage.read(key: 'user_id'), isNull);
      expect(await secureStorage.read(key: 'user_username'), isNull);
      expect(await secureStorage.read(key: 'user_email'), isNull);
    });

    test('ApiClient Interceptor automatically injects Authorization Bearer header when token exists', () async {
      await secureStorage.write(key: 'jwt_token', value: 'valid_bearer_token');

      final dio = Dio();
      dio.interceptors.clear();

      final apiClient = ApiClient(customDio: dio, customStorage: secureStorage);

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.headers['Authorization'], 'Bearer valid_bearer_token');
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'status': 'authorized'},
          ));
        },
      ));

      final res = await apiClient.dio.get('/test/protected');
      expect(res.statusCode, 200);
      expect(res.data['status'], 'authorized');
    });

    test('ApiClient Interceptor omits Authorization header when user is unauthenticated', () async {
      final dio = Dio();
      dio.interceptors.clear();

      final apiClient = ApiClient(customDio: dio, customStorage: secureStorage);

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.headers['Authorization'], isNull);
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'status': 'public'},
          ));
        },
      ));

      final res = await apiClient.dio.get('/test/public');
      expect(res.statusCode, 200);
      expect(res.data['status'], 'public');
    });

    test('Unauthorized 401 response invalidates local session and logs user out', () async {
      await secureStorage.write(key: 'jwt_token', value: 'expired_token');
      await secureStorage.write(key: 'user_id', value: 'usr_expired');

      final dio = Dio();
      dio.interceptors.clear();

      final apiClient = ApiClient(customDio: dio, customStorage: secureStorage);

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/auth/me')) {
            return handler.reject(DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 401,
                data: {'error': 'Invalid or expired token'},
              ),
              type: DioExceptionType.badResponse,
            ));
          }
          return handler.next(options);
        },
      ));

      final authRepo = AuthRepository(apiClient: apiClient);
      final user = await authRepo.restoreSession();

      expect(user, isNull);
      expect(await secureStorage.read(key: 'jwt_token'), isNull);
    });

    test('Forbidden 403 response triggers session termination', () async {
      await secureStorage.write(key: 'jwt_token', value: 'revoked_token');

      final dio = Dio();
      dio.interceptors.clear();

      final apiClient = ApiClient(customDio: dio, customStorage: secureStorage);

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/auth/me')) {
            return handler.reject(DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 403,
                data: {'error': 'Forbidden access'},
              ),
              type: DioExceptionType.badResponse,
            ));
          }
          return handler.next(options);
        },
      ));

      final authRepo = AuthRepository(apiClient: apiClient);
      final user = await authRepo.restoreSession();

      expect(user, isNull);
      expect(await secureStorage.read(key: 'jwt_token'), isNull);
    });
  });
}
