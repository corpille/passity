part of components;

@Component(
    selector: 'add-password',
    templateUrl: 'forms/add_password/add_password.html')
class AddPassword implements OnInit {
  Session session;
  Map password = new Map();
  var hasError = false;
  final Router _router;
  final RouteParams _routeParams;
  final SessionManager _sessionManager;
  final SrvPassword _srvPassword;

  AddPassword(
      this._router, this._routeParams, this._sessionManager, this._srvPassword);

  @override
  ngOnInit() {
    session = _sessionManager.session;
    if (!session.isAuth) {
      _router.navigate(["Dashboard", {}]);
    }
  }

  onSubmit() async {
    try {
      await _srvPassword.addPassword(password);
    } catch (e) {
      hasError = e.text;
    }
  }
}
