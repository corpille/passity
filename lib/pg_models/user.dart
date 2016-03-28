part of pg_models;

@Table("users")
class User extends PgModel {
  @Field(view: "login")
  String login;

  @Field(view: "password")
  String password;

  @Field(view: "key")
  String key;

  @OneToMany()
  List<PasswordRole> passwordroles;

  String session_token;

  User() {
    passwordroles = new List();
  }

  User escape() {
    password = null;
    key = null;
    return this;
  }

  Future findByEmail(String login) async {
    String query = "SELECT * from users WHERE login = '${login}'";
    List<PgModel> models = await new ORM().query(query, User);
    if (models.length > 0) {
      return models.first;
    }
    return null;
  }

  List<Password> getPassword() {
    List<Password> passwords = new List();
    passwordroles.forEach((PasswordRole passwordrole) {
      passwords.add(passwordrole.password);
    });
    return passwords;
  }
}
