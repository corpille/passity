part of models;

class User extends Model {
  //==== code generated ====
  Map toJson() {
    var map = super.toJson();
    map['login'] = login;
    map['password'] = password;
    map['session_token'] = session_token;
    map['passwords'] = passwords;
    return map;
  }

  void checkData(Map data) {
    super.checkData(data);
    if (data.containsKey('login') && data['login'].toString() != login.toString()) login = data['login'];
    if (data.containsKey('password') && data['password'].toString() != password.toString()) password = data['password'];
    if (data.containsKey('session_token') && data['session_token'].toString() != session_token.toString()) session_token = data['session_token'];
    if (data.containsKey('passwords') && data['passwords'].toString() != passwords.toString()) passwords = data['passwords'];
  }

  User clone() {
    var model = new User();
    model.login = login;
    model.password = password;
    model.session_token = session_token;
    model.passwords = passwords;
    return model;
  }

  Model newThis() => new User();
  //== end code generated ==
  @Expose()
  String login;

  @Expose()
  String password;

  @Expose()
  String session_token;

  @Expose()
  List<Password> passwords;
}
