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
    return encodeJson(password);
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
    return encodeJson(password);
  }
}
