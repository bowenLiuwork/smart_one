class UserInfoManager {
  //单例 --------
  factory UserInfoManager() => _getInstance();

  static UserInfoManager get instance => _getInstance();

  static UserInfoManager _instance;

  UserInfoManager._internal() {
    // 初始化
  }

  static UserInfoManager _getInstance() {
    if (_instance == null) {
      _instance = new UserInfoManager._internal();
    }
    return _instance;
  }

//-------------------

  String _token;

  String getToken() {
    return _token;
  }

  void setToken(var token) {
    _token = token;
  }
}
