part of models;

@Table("users")
class User extends Model {
  @Field(view: "login")
  String login;

  @Field(view: "password")
  String password;

  @Field(view: "key")
  String key;

  String session_token;

  User escape() {
    password = "";
    return this;
  }
}
