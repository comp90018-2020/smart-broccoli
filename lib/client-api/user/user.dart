import 'package:injectable/injectable.dart';
import '../../models/user.dart';
import './user_api.dart';

@singleton
class UserService {
  UserApi _userApi;

  UserService(this._userApi);

  Future<RegisteredUser> getUser() async {
    RegisteredUser user = await _userApi.getUser();
    return user;
  }
}
