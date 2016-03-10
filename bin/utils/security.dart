part of api;

class Secure {
  final List<UserType> roles;

  const Secure(this.roles);
}

class CurrentUser {
  const CurrentUser();
}

class CurrentUid {
  const CurrentUid();
}

class CurrentToken {
  const CurrentToken();
}

void SecurityPlugin(app.Manager manager) {
  manager.addRouteWrapper(Secure, (metadata, injector, request, route) async {
    var session = new Session(request);
    if (await session.isConnected()) {
      List<UserType> roles = (metadata as Secure).roles;
      if (!session.hasRole(roles)) {
        return new app.ErrorResponse(403, {"error": "NOT_AUTHORIZED"});
      }
      return route(injector, request);
    }
    throw ErrorResponse.notConnected();
  }, includeGroups: true);

  manager.addParameterProvider(
      CurrentUser,
      (metadata, type, handlerName, paramName, req, injector) async =>
          await new Session(req).getUser());

  manager.addParameterProvider(
      CurrentUid,
      (metadata, type, handlerName, paramName, req, injector) =>
          new Session(req).getUID());

  manager.addParameterProvider(
      CurrentToken,
      (metadata, type, handlerName, paramName, req, injector) =>
          new Session(req).getToken());
}
