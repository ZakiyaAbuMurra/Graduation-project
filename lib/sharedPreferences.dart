import 'package:shared_preferences/shared_preferences.dart';

class sharedPreferences{
  static SharedPreferences? _preferences;

  static Future init() async =>
  _preferences = await SharedPreferences.getInstance();

  static Future setLocationStatus(bool enabled) async =>
  await _preferences?.setBool("enabledLocation", enabled);

  static bool? getLocationStatus() => _preferences?.getBool("enabledLocation");

  static Future setLatitude(double latitude) async =>
  await _preferences?.setDouble("latitude", latitude);

  static double? getLatitude() => _preferences?.getDouble("latitude");

    static Future setLongitude(double longitude) async =>
  await _preferences?.setDouble("longitude", longitude);

  static double? getLongitude() => _preferences?.getDouble("longitude");

  

   
}