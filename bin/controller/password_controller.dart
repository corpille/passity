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

  /// Delete a password
  @app.Route("/:id", methods: const [app.DELETE])
  Future deletePassword(String id) async {
    Password password = await new Password().findById(id);
    if (password == null) {
      return ErrorResponse.userNotFound();
    }
    await password.delete();
    return {"success": true};
  }

  /// Get a users passwords
  @app.Route("/by-user/:id", methods: const [app.GET])
  Future getUserPasswords(String id) async {
    User user = await new User().findById(id);
    if (user == null) {
      throw ErrorResponse.userNotFound();
    }
    return user.getPassword();
  }

  @app.Route("/:id/decoded", methods: const [app.GET])
  Future getDecodedPassword(@CurrentUser() futureUser, @CurrentToken() String token, String id) async {
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
    if (password.passwordroles.where((PasswordRole pr) => pr.user.id == user.id).length != 1) {
      throw ErrorResponse.notYours();
    }
    for (Hash hash in password.hashes) {
      if (hash.isGoodHash(user.key, token)) {
        return {"decoded": hash.getPassword(user.key, token)};
      }
    }
    throw ErrorResponse.internalError();
  }

  @app.Route("/:id/share", methods: const [app.POST])
  Future sharePassword(@app.Body(app.JSON) Map data) {
    throw ErrorResponse.internalError();
  }

  /// Create a new password
  @app.Route("/", methods: const [app.PUT])
  Future putPassword(@CurrentUser() futureUser, @CurrentToken() String token, @app.Body(app.JSON) Map data) async {
    if (data == null || !(data is Map) || !data.containsKey("name") || !data.containsKey("pass")) {
      throw ErrorResponse.invalidJson();
    }
    Password password = new Password();
    password.name = data["name"];
    try {
      User user = await futureUser;
      password = await password.save();
      PasswordRole pr = new PasswordRole();
      pr.password = password;
      pr.user = user;
      pr.role = UserType.ADMIN.index;
      try {
        await pr.save();
      } catch (e) {
        print(e);
      }

      Hash hash = new Hash.fromPassword(user.key, data["pass"], token);
      hash.password = password;
      await hash.save();
    } catch (e) {
      throw ErrorResponse.internalError();
    }
    return password;
  }
}
