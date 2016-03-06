part of models;

enum UserType { ADMIN, EDIT, READ }

@Table("users")
class User extends Model {
  //==== code generated ====
  Map toJson() {
    var map = super.toJson();
    map['login'] = login;
    map['password'] = password;
    map['key'] = key;
    map['role'] = role;
    map['session_token'] = session_token;
    return map;
  }

  void checkData(Map data) {
    super.checkData(data);
    if (data.containsKey('login') && data['login'].toString() != login.toString()) login = data['login'];
    if (data.containsKey('password') && data['password'].toString() != password.toString()) password = data['password'];
    if (data.containsKey('key') && data['key'].toString() != key.toString()) key = data['key'];
    if (data.containsKey('role') && data['role'].toString() != role.toString()) role = data['role'];
    if (data.containsKey('session_token') && data['session_token'].toString() != session_token.toString()) session_token = data['session_token'];
  }

  User clone() {
    var model = new User();
    model.login = login;
    model.password = password;
    model.key = key;
    model.role = role;
    model.session_token = session_token;
    return model;
  }

  Model newThis() => new User();
  //== end code generated ==

  @Field(view: "login")
  String login;

  @Field(view: "password")
  String password;

  @Field(view: "key")
  String key;

  @Field(view: "role")
  int role = UserType.READ.index;

  @Expose()
  String session_token;

  User escape() {
    password = null;
    key = null;
    return this;
  }
}
