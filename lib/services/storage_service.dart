import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';
  static const String _businessIdKey = 'business_id';
  static const String _termsAcceptedKey = 'terms_accepted';
  static const String _email = 'email_saved';
  static const String _password = 'password_saved';

  /// Save authentication token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }


  static Future<void> saveCredential(String email ,String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_email, email);
    await prefs.setString(_password, password);
  }
  /// Get authentication token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Save user ID
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Save user email
  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Save user name
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  /// Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// Save user role (business, provider, user, event_manager)
  static Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
  }

  /// Get user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  /// Save business ID (for business role)
  static Future<void> saveBusinessId(String businessId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessIdKey, businessId);
  }

  /// Get business ID
  static Future<String?> getBusinessId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_businessIdKey);
  }

  /// Clear all stored data (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final termsAccepted = prefs.getBool(_termsAcceptedKey) ?? false;

    // Preserve remember me state and saved credentials for all roles
    final roles = ['user', 'provider', 'business', 'event_manager'];
    final Map<String, bool> rememberMeValues = {};
    final Map<String, String> emailValues = {};
    final Map<String, String> passwordValues = {};

    // for (final r in roles) {
    //   rememberMeValues[r] = prefs.getBool('remember_me_$r') ?? false;
    //   final e = prefs.getString('saved_email_$r');
    //   if (e != null) emailValues[r] = e;
    //   final p = prefs.getString('saved_password_$r');
    //   if (p != null) passwordValues[r] = p;
    // }

    await prefs.clear();

    if (termsAccepted) {
      await prefs.setBool(_termsAcceptedKey, true);
    }

    // Restore remember me credentials
    for (final r in roles) {
      if (rememberMeValues[r] == true) {
        await prefs.setBool('remember_me_$r', true);
      }
      final e = emailValues[r];
      if (e != null) {
        await prefs.setString('saved_email_$r', e);
      }
      final p = passwordValues[r];
      if (p != null) {
        await prefs.setString('saved_password_$r', p);
      }
    }
  }

  /// Save terms accepted state
  static Future<void> saveTermsAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_termsAcceptedKey, accepted);
  }

  /// Get terms accepted state
  static Future<bool> isTermsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_termsAcceptedKey) ?? false;
  }

  /// Save remember me state
  static Future<void> saveRememberMe(String role, bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me_$role', remember);
  }

  /// Get remember me state
  static Future<bool> getRememberMe(String role) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember_me_$role') ?? false;
  }

  /// Save credentials
  static Future<void> saveSavedCredentials(String role, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email_$role', email);
    await prefs.setString('saved_password_$role', password);
  }

  /// Get saved email
  static Future<String?> getSavedEmail(String role) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_email_$role');
  }

  /// Get saved password
  static Future<String?> getSavedPassword(String role) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_password_$role');
  }

  /// Clear saved credentials
  static Future<void> clearSavedCredentials(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email_$role');
    await prefs.remove('saved_password_$role');
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
