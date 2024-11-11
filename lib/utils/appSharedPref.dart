import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefre{

  SharedPrefre._();
  static String _KEY_USER_ID = "userid";
  static String _KEY_USER_EMAIL = "useruEmail";
  static String _KEY_USER_PHONENUMBER = "userPhoneNumber";
  static String _KEY_USER_NAME = "userName";
  static String KEY_PROFILE ="profile";
  static String  _KEY_CURRENT_LATITUDE ="0";
  static String  _KEY_CURRENT_LONGITUDE ="0";
  static String  _KEY_CURRENT_LATITUDE_LONGITUDE ="0";


  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //==========>>>> save detail method<<<<<=============\\

  static void saveUserId(int  uid) async{
    final SharedPreferences prefs = await _prefs;
    prefs.setInt(_KEY_USER_ID , uid);
  }

  static void saveUserEmail(String  uEmail) async{
    final SharedPreferences prefs = await _prefs;
    prefs.setString(_KEY_USER_EMAIL , uEmail);
  }

 static void saveUserName(String  uName) async{
    final SharedPreferences prefs = await _prefs;
    prefs.setString(_KEY_USER_NAME , uName);
  }

  static void saveUserPhoneNumber(String  uPhoneNumber) async{
    final SharedPreferences prefs = await _prefs;
    prefs.setString(_KEY_USER_PHONENUMBER , uPhoneNumber);
  }

  static void saveCurrentLatitude(String  uid) async{
    final SharedPreferences prefs = await _prefs;
    prefs.setString(_KEY_CURRENT_LATITUDE , uid);
  }

  static void saveCurrentLongitude(String  uid) async{
    final SharedPreferences prefs = await _prefs;
    prefs.setString(_KEY_CURRENT_LONGITUDE , uid);
  }

  static void saveProfile(String  profile) async{
    final SharedPreferences prefs = await _prefs;
    prefs.setString(KEY_PROFILE , profile);
  }



  //========>>>>> get method <<<===============\\


  static Future<int?> getUserId()async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getInt(_KEY_USER_ID);
  }

  static Future<String> getUserEmail()async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_KEY_USER_EMAIL)??"";
  }

  static Future<String> getUserPhoneNumber()async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_KEY_USER_PHONENUMBER)??"";
  }

  static Future<String> getUserName()async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_KEY_USER_NAME)??"";
  }
  static Future<String> getUserProfile()async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(KEY_PROFILE)??"";
  }

  static Future<String> getCurrentLatitude()async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_KEY_CURRENT_LATITUDE)??"";
  }

  static Future<String> getCurrentLongitude()async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_KEY_CURRENT_LONGITUDE)??"";
  }

  static Future<void> clearSharedPre() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.clear();

  }

}