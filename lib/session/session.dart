part of session;

class Session {
  bool isAuth = false;
  String uid = null;
  String login = null;

  void update(User user) {
    uid = user.id;
    login = user.login;
  }

  void delete() {
    isAuth = false;
    uid = null;
    login = null;
  }

  String toString() {
    return "{isAuth: ${isAuth}, uid: \"${uid}\", login: \"${login}\"}";
  }
}
