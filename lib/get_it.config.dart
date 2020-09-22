// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'client-api/api_base.dart';
import 'client-api/auth/auth_api.dart';
import 'client-api/auth/auth.dart';
import 'repository.dart';
import 'client-api/user/user_api.dart';
import 'client-api/user/user.dart';

/// adds generated dependencies
/// to the provided [GetIt] instance

GetIt $initGetIt(
  GetIt get, {
  String environment,
  EnvironmentFilter environmentFilter,
}) {
  final gh = GetItHelper(get, environment, environmentFilter);

  // Eager singletons must be registered in the right order
  gh.singleton<ApiBase>(ApiBase());
  gh.singleton<AuthApi>(AuthApi());
  gh.singletonAsync<AuthService>(() => AuthService.create(get<AuthApi>()));
  gh.singletonWithDependencies<Repository>(() => Repository(get<AuthService>()),
      dependsOn: [AuthService]);
  gh.singleton<UserApi>(UserApi(get<ApiBase>()));
  gh.singleton<UserService>(UserService(get<UserApi>()));
  return get;
}
