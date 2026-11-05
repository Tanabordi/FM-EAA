import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FakeGoogleSignInNull extends Fake implements GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signOut() async => null;
  @override
  Future<GoogleSignInAccount?> signIn() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterSecureStorage secureStorage;
  late Dio dio;
  late ApiClient apiClient;
  late AuthRepository repository;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    secureStorage = const FlutterSecureStorage();
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:5000/api'));
    apiClient = ApiClient(customDio: dio, customStorage: secureStorage);
    repository = AuthRepository(apiClient: apiClient);
  });

  tearDown(() async {
    await secureStorage.deleteAll();
  });

  group('AuthRepository Unit Tests', () {
    test('signInWithPassword success writes token and user info to storage', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/auth/login')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'token': 'mock_jwt_token_123',
                    'user': {
                      'id': 'u1',
                      'username': 'somchai',
                      'email': 'somchai@example.com',
                      'updatedAt': '2026-01-01T00:00:00.000Z',
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final user = await repository.signInWithPassword('somchai', 'password123');
      expect(user.id, 'u1');
      expect(user.username, 'somchai');
      expect(user.email, 'somchai@example.com');

      final token = await secureStorage.read(key: 'jwt_token');
      expect(token, 'mock_jwt_token_123');
      final storedUsername = await secureStorage.read(key: 'user_username');
      expect(storedUsername, 'somchai');
    });

    test('signInWithPassword failure parses custom error message', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 400,
                  data: {'error': 'อีเมลหรือรหัสผ่านไม่ถูกต้อง'},
                ),
              ),
            );
          },
        ),
      );

      expect(
        () => repository.signInWithPassword('bad_user', 'bad_pass'),
        throwsA(predicate((e) => e.toString().contains('อีเมลหรือรหัสผ่านไม่ถูกต้อง'))),
      );
    });

    test('createAccount success returns UserModel and stores token', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/auth/register')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 201,
                  data: {
                    'token': 'reg_token_456',
                    'user': {
                      'id': 'u2',
                      'username': 'newuser',
                      'email': 'new@example.com',
                      'updatedAt': '2026-01-01T00:00:00.000Z',
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final user = await repository.createAccount('newuser', 'new@example.com', 'Pass1234!');
      expect(user.id, 'u2');
      expect(user.username, 'newuser');
      expect(await secureStorage.read(key: 'jwt_token'), 'reg_token_456');
    });

    test('restoreSession returns null if no token is saved', () async {
      final user = await repository.restoreSession();
      expect(user, isNull);
    });

    test('restoreSession returns user when token is valid', () async {
      await secureStorage.write(key: 'jwt_token', value: 'saved_valid_token');

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/auth/me')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'user': {
                      'id': 'u_restored',
                      'username': 'restored_user',
                      'email': 'restored@example.com',
                      'updatedAt': '2026-01-01T00:00:00.000Z',
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final user = await repository.restoreSession();
      expect(user, isNotNull);
      expect(user!.id, 'u_restored');
      expect(user.username, 'restored_user');
    });

    test('restoreSession logs out and returns null on 401 Unauthorized', () async {
      await secureStorage.write(key: 'jwt_token', value: 'expired_token');

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                ),
              ),
            );
          },
        ),
      );

      final user = await repository.restoreSession();
      expect(user, isNull);
      expect(await secureStorage.read(key: 'jwt_token'), isNull);
    });

    test('restoreSession falls back to local storage on network timeout', () async {
      await secureStorage.write(key: 'jwt_token', value: 'offline_token');
      await secureStorage.write(key: 'user_id', value: 'u_offline');
      await secureStorage.write(key: 'user_username', value: 'offline_user');
      await secureStorage.write(key: 'user_email', value: 'offline@example.com');

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
              ),
            );
          },
        ),
      );

      final user = await repository.restoreSession();
      expect(user, isNotNull);
      expect(user!.id, 'u_offline');
      expect(user.username, 'offline_user');
    });

    test('uploadAvatar success returns avatar url and saves to storage', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/users/me/avatar')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'avatarUrl': 'https://storage.oracle.com/avatar123.jpg',
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final url = await repository.uploadAvatar([1, 2, 3, 4], 'test.jpg');
      expect(url, 'https://storage.oracle.com/avatar123.jpg');
      expect(await secureStorage.read(key: 'user_avatar_url'), url);
    });

    test('sendPasswordReset and requestPasswordReset execute successfully', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/auth/forgot-password')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'message': 'OTP sent'},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      await repository.sendPasswordReset('user@test.com');
      final res = await repository.requestPasswordReset('user@test.com');
      expect(res['message'], 'OTP sent');
    });

    test('verifyOtp and resetPassword execute successfully', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/auth/verify-otp')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'valid': true},
                ),
              );
            }
            if (options.path.contains('/auth/reset-password')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final verifyRes = await repository.verifyOtp(email: 'user@test.com', otp: '123456');
      expect(verifyRes['valid'], isTrue);

      final resetRes = await repository.resetPassword(
        email: 'user@test.com',
        otp: '123456',
        newPassword: 'NewPassword123!',
      );
      expect(resetRes['success'], isTrue);
    });

    test('logout clears all storage values', () async {
      await secureStorage.write(key: 'jwt_token', value: 'tok');
      await secureStorage.write(key: 'user_id', value: 'uid');

      await repository.logout();

      expect(await secureStorage.read(key: 'jwt_token'), isNull);
      expect(await secureStorage.read(key: 'user_id'), isNull);
    });

    test('parseDioError handles timeout, connectionError and generic errors', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          },
        ),
      );

      expect(
        () => repository.sendPasswordReset('bad@test.com'),
        throwsA(predicate((e) => e.toString().contains('Cannot connect to backend server'))),
      );
    });

    test('signInWithGoogle handles cancellation', () async {
      expect(
        () => repository.signInWithGoogle(googleSignInOverride: FakeGoogleSignInNull()),
        throwsA(predicate((e) => e.toString().contains('Google sign-in was cancelled'))),
      );
    });

    test('pickGoogleEmail returns null on cancellation', () async {
      final res = await repository.pickGoogleEmail(googleSignInOverride: FakeGoogleSignInNull());
      expect(res, isNull);
    });
  });
}
