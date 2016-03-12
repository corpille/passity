part of api;

class ErrorResponse {
  static String _createErrorJson(String error) => JSON.encode({"error": error});

  /// Unidentified errors
  static internalError() =>
      new app.ErrorResponse(500, "Something wrong hapened");

  /// Identified errors
  static notYours() =>
      new app.ErrorResponse(401, _createErrorJson("Not yours"));
  static notConnected() =>
      new app.ErrorResponse(401, _createErrorJson("Not connected"));
  static viewFailed() =>
      new app.ErrorResponse(400, _createErrorJson("View failed"));
  static invalidJson() =>
      new app.ErrorResponse(400, _createErrorJson("Invalid JSON"));
  static failedWrite() =>
      new app.ErrorResponse(400, _createErrorJson("Failed to write"));
  static failedDelete() =>
      new app.ErrorResponse(400, _createErrorJson("Failed to delete"));
  static failedEmail() =>
      new app.ErrorResponse(400, _createErrorJson("Failed to send the mail"));

  /// User
  static userInvalid() =>
      new app.ErrorResponse(400, _createErrorJson("User sent is not valid"));
  static userLoginAlreadyUsed() =>
      new app.ErrorResponse(400, _createErrorJson("Login already used"));
  static userNotFound() =>
      new app.ErrorResponse(404, _createErrorJson("User not found"));
  static loginNotFound() =>
      new app.ErrorResponse(404, _createErrorJson("Login not found"));
  static userBadCredentials() =>
      new app.ErrorResponse(401, _createErrorJson("Bad username or password"));
  static userBadPassword() =>
      new app.ErrorResponse(401, _createErrorJson("Bad password"));
  static userBadLogin() =>
      new app.ErrorResponse(401, _createErrorJson("Bad login"));
  static tokenNotFound() =>
      new app.ErrorResponse(404, _createErrorJson("Token not found"));
  static loginError() =>
      new app.ErrorResponse(500, _createErrorJson("Error while connecting"));

  /// Password
  static passwordNotFound() =>
      new app.ErrorResponse(404, _createErrorJson("Password not found"));
}
