import 'package:fuzzy_broccoli/client-api/auth/auth.dart';
import 'package:injectable/injectable.dart';

@Singleton(dependsOn: [AuthService])
class Repository {
  Repository(this._authService);

  AuthService _authService;
  AuthService get authService {
    return _authService;
  }
}
