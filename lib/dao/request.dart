part of dao;

class Request {
  String session_token;
  String _url;

  Request(this._url);

  String _toUrl(String input) => _url + "/" + input;

  Future<HttpRequest> send(String method, String reponseType, String api_path, {data: null}) {
    var c = new Completer();
    HttpRequest request = new HttpRequest();

    request
      ..withCredentials = true
      ..open(method, _toUrl(api_path), async: true);
    if (session_token != null) {
      request.setRequestHeader("authorization", session_token);
    }
    request
      ..responseType = "text"
      ..onError.listen((e) => c.completeError(request))
      ..onLoad.listen((e) => c.complete(request));

    if (data != null) {
      request.setRequestHeader("Content-type", "application/json");
    }
    request.send(data);
    return c.future;
  }

  /// Users
  Future<HttpRequest> isAuth() => send("GET", "text", "isAuth");
  Future<HttpRequest> signIn(String user) => send("POST", "json", "user/sign-in", data: user);
  Future<HttpRequest> getUser(String id) => send("GET", "json", "user/" + id);

  /// Passwords
  Future<HttpRequest> addPassword(String password) => send("PUT", "json", "password/", data: password);
  Future<HttpRequest> getPasswordByUser(String userId) => send("GET", "json", "/password/by-user/" + userId);
  Future<HttpRequest> getDecodePassword(String id) => send("GET", "json", "password/" + id + "/decoded");
  Future<HttpRequest> deletePassword(String id) => send("DELETE", "json", "password/" + id);
}
