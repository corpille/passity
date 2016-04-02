part of models;

@Serializable()
class User extends Model {

  String login;

  String password;

  String session_token;

  @OneToMany(Password)
  List<Password> passwords;

}
