// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'client-api/auth.dart';
import 'repository.dart';
import 'client-api/user.dart';

/// adds generated dependencies
/// to the provided [GetIt] instance

GetIt $initGetIt(
  GetIt get, {
  String environment,
  EnvironmentFilter environmentFilter,
}) {
  final gh = GetItHelper(get, environment, environmentFilter);

  // Eager singletons must be registered in the right order
  gh.singletonAsync<AuthService>(() => AuthService.create());
  gh.singletonWithDependencies<Repository>(() => Repository(get<AuthService>()),
      dependsOn: [AuthService]);
  gh.singleton<UserService>(UserService(get<AuthService>()));
  return get;
}
