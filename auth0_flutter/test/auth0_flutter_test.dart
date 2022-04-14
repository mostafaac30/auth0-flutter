import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel =
      MethodChannel('auth0.com/auth0_flutter/web_auth');

  TestWidgetsFlutterBinding.ensureInitialized();

  final Map<dynamic, dynamic> loginResult = {
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': '2022-04-05',
    'scopes': ['a'],
    'userProfile': {'sub': '123', 'name': 'John Doe'}
  };
  setUp(() {
    channel.setMockMethodCallHandler(
        (final MethodCall methodCall) async => loginResult);
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('login', () async {
    final result = await Auth0('test', 'test').webAuthentication.login();
    expect(result.accessToken, loginResult['accessToken']);
  });
}
