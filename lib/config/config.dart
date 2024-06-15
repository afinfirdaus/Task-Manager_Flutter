// ignore_for_file: constant_identifier_names

class Config {
  static const String API_URL = 'http://10.60.226.133:8000';

  static const String LOGIN_URL = '$API_URL/api/login';
  static const String REGISTER_URL = '$API_URL/api/register';
  static const String DEVELOPER_TASK_URL = '$API_URL/api/developer-task';
  static const String COMMENT = '$API_URL/api/comment';
  static const String STORE_PROJECT = '$API_URL/api/store';
  static const String ADD_TASK = '$API_URL/api/add';
  static const String EDIT_TASK = '$API_URL/api/edit';
}
