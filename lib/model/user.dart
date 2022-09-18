import 'package:shared_preferences/shared_preferences.dart';

/// "idsAccount" "idsPassword" "sportPassword"
Map<String, String?> user = {
  "name": null,
  "sex": null,
  "execution": null,
  "institutes": null,
  "subject": null,
  "dorm": null,
  "idsAccount": null,
  "idsPassword": null,
  "sportPassword": null,
};

Future<void> initUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  user["idsAccount"] = prefs.getString("idsAccount");
  user["idsPassword"] = prefs.getString("idsPassword");

  /// Temporary solution.
  user["sportPassword"] = prefs.getString("sportPassword");
  if (user["idsAccount"] == null ||
      user["idsPassword"] == null ||
      user["sportPassword"] == null) {
    throw "有未注册用户，跳转至登录界面";
  }
  user["name"] = prefs.getString("name");
  user["sex"] = prefs.getString("sex");
  user["execution"] = prefs.getString("execution");
  user["institutes"] = prefs.getString("institutes");
  user["subject"] = prefs.getString("subject");
  user["dorm"] = prefs.getString("dorm");
}

Future<void> addUser(String key, String value) async {
  user[key] = value;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}
