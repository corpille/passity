part of session;

class Session {
  bool isAuth = false;
  User user;

  void update(User u) {
    user = u;
  }

  void delete() {
    isAuth = false;
    user = null;
  }

  String toString() {
    return "{isAuth: ${isAuth}, user: \"${user}\"}";
  }
}
