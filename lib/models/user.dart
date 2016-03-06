part of models;

enum UserType { ADMIN, EDIT, READ }

@Table("users")
class User extends Model {
  @Field(view: "login")
  String login;

  @Field(view: "password")
  String password;

  @Field(view: "key")
  String key;

  @Field(view: "role")
  int role = UserType.READ.index;

  String session_token;

  User escape() {
    password = null;
    key = null;
    return this;
  }
}
