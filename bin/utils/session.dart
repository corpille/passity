part of api;

class Session {
  static const int EXPIRATION_SESSION = 21; // days

  static const int MAX_API_CALLS_DELAY = 60 * 60 * 24; // daily
  static const int MAX_API_CALLS = 50000; // until 50.000 calls daily

  static const String SESSION_HEADER = "authorization";

  static const _sharedSecret = "mybeautifulsecret";
  final _signatureContext = new JwaSymmetricKeySignatureContext(_sharedSecret);

  app.Request _req = null;

  Session(this._req);

  ////
  /// Session IDs are store in cookies
  ///
  Future<bool> isConnected() async {
    String uid = await getUID();
    return (uid == null) ? false : true;
  }

  Future disconnect() async {}

  ///
  /// Generate a jwt token for the current session
  ///
  String connect(User user) {
    var claimSet = new MapJwtClaimSet({
      "uid": user.id,
      "role": user.role,
      "token": Encryption.SHA256(Encryption.SHA512(user.password))
    });
    final jwt = new JsonWebToken.jws(claimSet, _signatureContext);
    return jwt.encode();
  }

  Map get _currentSession {
    if (_req.headers[SESSION_HEADER] == null) {
      return null;
    }
    return new JsonWebToken.decode(_req.headers[SESSION_HEADER],
            claimSetParser: mapClaimSetParser)
        .claimSet
        .toMap();
  }

  String getUID() {
    if (_req.headers.containsKey(SESSION_HEADER)) {
      return _currentSession["uid"];
    }
    return null;
  }

  String getToken() {
    if (_req.headers.containsKey(SESSION_HEADER)) {
      return _currentSession["token"];
    }
    return null;
  }

  bool hasRole(List<UserType> roles) {
    if (_currentSession == null) {
      return false;
    }
    for (UserType role in roles) {
      if (_currentSession["role"] == role.index) {
        return true;
      }
    }
    return false;
  }

  Future<User> getUser() async {
    String uid = getUID();
    if (uid != null) {
      User user = await new User().findById(uid);
      if (user != null) {
        return user;
      }
    }
    return null;
  }
}
