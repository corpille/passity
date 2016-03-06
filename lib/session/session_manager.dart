part of session;

@Injectable()
class SessionManager {
  final String _LOCAL_STORAGE_KEY = "session_token";

  Session _session = new Session();
  Dao _dao;

  static final SessionManager _sessionManger = new SessionManager._internal();

  factory SessionManager.fromDao(Dao dao) {
    _sessionManger._dao = dao;
    var session_token = window.localStorage[_sessionManger._LOCAL_STORAGE_KEY];
    _sessionManger._dao.session_token = session_token;
    return _sessionManger;
  }

  factory SessionManager() {
    return _sessionManger;
  }

  SessionManager._internal();

  Future isStillAuth() async {
    try {
      var res = await _dao.isAuth();
      if (res is bool && res == false) {
        throw res;
      }
      updateSession(res as User);
      session.isAuth = true;
    } catch (e) {
      deleteSession();
    }
  }

  deleteSession() {
    _dao.session_token = null;
    window.localStorage.remove(_LOCAL_STORAGE_KEY);
    _session.delete();
  }

  Future signIn(String login, String password) async {
    Map data = new Map();
    data["login"] = login;
    data["password"] = password;
    try {
      User user = await _dao.signIn(data);
      session.isAuth = true;
      updateSession(user);
      return true;
    } catch (e) {
      deleteSession();
      throw e;
    }
  }

  Future logout() async {
    try {
      await _dao.logout();
      return true;
    } catch (e) {
      return false;
    } finally {
      deleteSession();
    }
  }

  void updateSession(User user) {
    if (user.session_token != null && user.session_token != "") {
      _dao.session_token = user.session_token;
      window.localStorage[_LOCAL_STORAGE_KEY] = user.session_token;
    }
    if (user.id != null && user.login != null) {
      _session.update(user);
    }
  }

  Session get session => _session;
}
