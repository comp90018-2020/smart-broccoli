import '../models/user.dart';
import '../store/remote/auth.dart';
import '../store/local/key_value.dart';
import '../store/local/null_key_value.dart';
import '../store/remote/user.dart';

main() async {
  KeyValueStore kv = NullKeyValueStore();
  AuthModel am = AuthModel(kv);
  UserModel um = UserModel(am);

  RegisteredUser user = await um.updateUser(email: "unimelb@alanung.com");
  print(user.name);
  print(user.email);
}
