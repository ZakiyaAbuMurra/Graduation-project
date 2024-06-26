class ApiPaths {
  static String user() => 'users/'; 
  static String users(String uid) => 'users/$uid';
  static String messages() => 'messages/';
  static String sendMessage(String id) => 'messages/$id';

}
