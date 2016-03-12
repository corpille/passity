part of api;

/// Controller that manage all the user queries
@app.Group('/password')
class PasswordController {
  /// Get a password
  @app.Route("/:id", methods: const [app.GET])
  Future getPassword(String id) async {
    Password password = await new Password().findById(id);
    if (password == null) {
      return ErrorResponse.userNotFound();
    }
    return password;
  }

  /// Get a users passwords
  @app.Route("/by-user/:id", methods: const [app.GET])
  Future getUserPasswords(String id) async {
    User user = await new User().findById(id);
    if (user == null) {
      throw ErrorResponse.userNotFound();
    }
    return user.passwords;
  }

  @app.Route("/:id/decoded", methods: const [app.GET])
  Future getDecodedPassword(@CurrentUser() futureUser,
      @CurrentToken() String token, String id) async {
    User user;
    try {
      user = await futureUser;
    } catch (e) {
      throw ErrorResponse.internalError();
    }
    if (user == null) {
      throw ErrorResponse.userNotFound();
    }
    Password password = await new Password().findById(id);
    if (password == null) {
      throw ErrorResponse.passwordNotFound();
    }
    if (password.users.where((u) => u.id == user.id).length != 1) {
      throw ErrorResponse.notYours();
    }
    for (Hash hash in password.hashes) {
      if (hash.isGoodHash(user.key, token)) {
        return {"decoded": hash.getPassword(user.key, token)};
      }
    }
    throw ErrorResponse.internalError();
  }

  /// Create a new password
  @Secure(const [UserType.ADMIN, UserType.EDIT])
  @app.Route("/", methods: const [app.PUT])
  Future putPassword(@CurrentUser() futureUser, @CurrentToken() String token,
      @app.Body(app.JSON) Map data) async {
    if (data == null ||
        !(data is Map) ||
        !data.containsKey("name") ||
        !data.containsKey("pass")) {
      throw ErrorResponse.invalidJson();
    }
    Password password = new Password();
    password.name = data["name"];
    try {
      User user = await futureUser;
      password.users.add(user);
      password = await password.save();
      Hash hash = new Hash.fromPassword(user.key, data["pass"], token);
      hash.password = password;
      await hash.save();
    } catch (e) {
      throw ErrorResponse.internalError();
    }
    return password;
  }
}
