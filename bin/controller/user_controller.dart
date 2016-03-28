part of api;

/// Controller that manage all the user queries
@app.Group('/user')
class UserController {
  /// Creates a new user
  @app.Route("/", methods: const [app.PUT])
  Future addUser(@Decode() User data) async {
    User user = await new User().findByEmail(data.login);
    if (user == null) {
      data.key = Encryption.generateKey(data.password);
      data.password = Encryption.SHA256(data.password);
      await data.save();
      return data.escape();
    }
    return ErrorResponse.userLoginAlreadyUsed();
  }

  /// Sign the user in
  @app.Route("/sign-in", methods: const [app.POST])
  Future signIn(@Decode() User data) async {
    User user = await new User().findByEmail(data.login);
    if (user != null) {
      if (user.password == Encryption.SHA256(data.password)) {
        try {
          user.password = data.password;
          var token = new Session(app.request).connect(user);
          user.session_token = token;
          var result = user.escape().toJson();
          result["session_token"] = token;
          return JSON.encode(result);
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
  Future getUser(@CurrentUid() uid, String id) async {
    if (id == "me") {
      id = uid;
    }

    User user = await new User().findById(id);
    if (user == null) {
      return ErrorResponse.userNotFound();
    }
    return user.escape();
  }
}
