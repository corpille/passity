part of dao;

class Dao {
  Request _req;

  set session_token(token) => _req.session_token = token;

  static final Dao _dao = new Dao._internal();

  factory Dao.fromUrl(String url) {
    _dao._req = new Request(url);
    return _dao;
  }

  factory Dao() {
    return _dao;
  }

  Dao._internal();

  Future _converter(Future<HttpRequest> futureRequest, callbackIfTrue(Map data)) async {
    HttpRequest request;
    try {
      request = await futureRequest;
    } on HttpRequest catch (request) {
      throw new DaoError(request.status, "Error in sending");
    }

    var data = request.response;
    if (data is String) {
      // IE + Safari patch
      data = JSON.decode(data);
    }
    if (request.status != 200) {
      if (data is Map && data.containsKey("error")) {
        throw new DaoError(request.status, data["error"]);
      } else {
        throw new DaoError(request.status, null);
      }
    }

    if (data != null && (data is Map || data is List)) {
      var result = callbackIfTrue(data);
      if (result is Error) {
        throw result.stackTrace;
      } else {
        return result;
      }
    } else {
      throw new DaoError(400, "Unknown Error");
    }
  }

  Future<Model> _toModel(Future<HttpRequest> futureRequest, Type type)
    => _converter(futureRequest, (Map data) => new Serializer().deserialize(data, type));

  bool _checkBoolean(Map map, String key) {
    if (map.containsKey(key) && (map[key] is bool)) {
      return map[key];
    }
    return false;
  }

  Future<List<Model>> _toModelList(Future<HttpRequest> futureRequest, Type type) =>
      _converter(futureRequest, (Map data) {
        List<Model> resultList = new List();
        for (var elem in data) {
          resultList.add(new Serializer().deserialize(elem, type));
        }
        return resultList;
      });

  Future<bool> isAuth() => _converter(_req.isAuth(), (Map data) {
        if (data.containsKey("isAuth") &&
            data["isAuth"] is bool &&
            data["isAuth"] &&
            data.containsKey("user") &&
            data["user"] is Map &&
            data["user"] != null) {
            return new Serializer().deserialize(data["user"], User);
        }
        return false;
      });

  /// Users
  Future<Model> signIn(Map login) => _toModel(_req.signIn(JSON.encode(login)), User);
  Future<Model> getUser(String id) => _toModel(_req.getUser(id), User);
  Future<Model> createUser(User user) {
      return _toModel(_req.createUser(new Serializer().serialize(user)), User);
  }
  Future<bool> logout() async => true;

  /// Passwords
  Future addPassword(Map password) => _toModel(_req.addPassword(JSON.encode(password)), Password);
  Future getPasswordByUser(String userId) => _toModelList(_req.getPasswordByUser(userId), Password);
  Future getDecodePassword(String id) => _converter(_req.getDecodePassword(id), (data) => data);
  Future deletePassword(String id) => _converter(_req.deletePassword(id), (Map data) => _checkBoolean(data, "success"));
}
