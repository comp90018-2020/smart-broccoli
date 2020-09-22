import 'package:injectable/injectable.dart';
import './auth_api.dart';
import '../../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton class for making requests requiring authorisation
@singleton
class AuthService {
  AuthApi _authApi;

  String _token;
  String get token {
    return _token;
  }

  AuthService(this._authApi, this._token);

  @factoryMethod
  static Future<AuthService> create(AuthApi authApi) async {
    // TODO: move SharedPreferences out of here
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    return AuthService(authApi, token);
  }

  Future<RegisteredUser> register(
      String email, String password, String name) async {
    RegisteredUser user = await _authApi.register(email, password, name);
    return user;
  }

  Future<bool> login(String email, String password) async {
    String _token = await _authApi.login(email, password);
    this._token = _token;
    return true;
  }
}
