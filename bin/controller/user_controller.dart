part of api;

/// Controller that manage all the user queries
@app.Group('/user')
class UserController {
  /// Creates a new user
  @app.Route("/", methods: const [app.PUT])
  Future addUser(@Decode() User user) async {
    List<User> users = await postgreSql.query(
        "SELECT * from users WHERE login = " + user.login, User);
    if (users != null && users.length == 0) {
      //encode user, and insert it in the "user" table.
      user.key = Encryption.generateKey(user.password);
      user.password = Encryption.SHA256(user.password);
      await postgreSql.execute(
          "insert into users (login, password, key)"
          "values (@login, @password, @key)",
          user);
      return encodeJson(user.escape());
    }
    return ErrorResponse.userLoginAlreadyUsed();
  }

  /// Sign the user in
  @app.Route("/sign-in", methods: const [app.POST])
  Future signIn(@Decode() User data) async {
    List<User> users = await postgreSql.query(
        "SELECT * from users WHERE login = " + data.login, User);
    if (users != null && users.length == 1) {
      User user = users.first;
      if (user.password == Encryption.SHA256(data.password)) {
        try {
          var token = new Session(app.request).connect(user);
          user.session_token = token;
          var data = JSON.decode(encodeJson(user.escape()));
          data["token"] = token;
          return JSON.encode(data);
        } catch (e) {
          throw ErrorResponse.loginError();
        }
      }
      throw ErrorResponse.userBadPassword();
    }
    throw ErrorResponse.loginNotFound();
  }

  /// Get a user
  @app.Route("/:id", methods: const [app.GET])
  Future getUser(String id) async {
    List<User> users = await postgreSql.query(
        "SELECT * from users WHERE id = '" + id + "'", User);
    if (users == null || users.length == 0) {
      return ErrorResponse.userNotFound();
    }
    return encodeJson(users.first.escape());
  }
}
