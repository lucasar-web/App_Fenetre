import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _userNameKey = 'user_name';

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }
}
