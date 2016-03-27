part of components;

@Component(selector: 'add-password', templateUrl: 'add-password/add-password.component.html')
class AddPassword implements OnInit {
  Session session;
  Map password = new Map();
  var error = false;
  var success = false;
  final Router _router;
  final SessionManager _sessionManager;
  final SrvPassword _srvPassword;

  AddPassword(this._router, this._sessionManager, this._srvPassword);

  @override
  ngOnInit() {
    session = _sessionManager.session;
    if (!session.isAuth) {
      _router.navigate(["Dashboard", {}]);
    }
  }

  onSubmit(NgForm addPasswordForm) async {
    try {
      await _srvPassword.addPassword(password);
      success = true;
      error = false;
      addPasswordForm.controls.forEach((name, control) {
        control.updateValue('');
        control.setErrors(null);
      });
    } catch (e) {
      print(e);
      success = false;
      error = true;
    }
  }
}
