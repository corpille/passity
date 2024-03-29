part of api;

@app.Group('/')
class APIController {
  @app.Route('/')
  Future info() async {
    return {"version": "0.1.0"};
  }

  @app.Route('/isAuth')
  Future isAuth(@CurrentUser() futureUser) async {
    try {
      User user = await futureUser;
      if (user == null) {
        throw ErrorResponse.notConnected();
      }
      return {"isAuth": true, "user": user.escape()};
    } catch (e) {
      return {"isAuth": false};
    }
  }
}
