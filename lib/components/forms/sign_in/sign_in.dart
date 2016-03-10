part of components;

@Component(selector: 'sign-in', templateUrl: 'forms/sign_in/sign_in.html')
class SignIn implements OnInit {
  Session session;
  User user = new User();
  var hasError = false;
  final Router _router;
  final RouteParams _routeParams;
  final SessionManager _sessionManager;

  SignIn(this._router, this._routeParams, this._sessionManager);

  @override
  ngOnInit() {
    session = _sessionManager.session;
    if (session.isAuth) {
      _router.navigate(["Dashboard", {}]);
    }
  }

  onSubmit() async {
    try {
      await _sessionManager.signIn(user.login, user.password);
    } catch (e) {
      hasError = e.text;
    }
    _router.navigate(["Dashboard", {}]);
  }
}
