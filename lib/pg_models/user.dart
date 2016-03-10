part of pg_models;

enum UserType { ADMIN, EDIT, READ }

@Table("users")
class User extends PgModel {
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

  Future findByEmail(String login) async {
    String query = "SELECT * from users WHERE login = '${login}'";
    List<PgModel> models = await new ORM().postgres.query(query, User);
    if (models.length > 0) {
      return models.first;
    }
    return null;
  }
}
