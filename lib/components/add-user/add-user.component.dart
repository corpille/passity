part of components;

@Component(selector: 'add-user', templateUrl: 'add-user/add-user.component.html')
class AddUser implements OnInit {
  Session session;
  User user = new User();
  var error = false;
  var success = false;
  final Router _router;
  final SessionManager _sessionManager;
  final SrvUser _srvUser;

  AddUser(this._router, this._sessionManager, this._srvUser);

  @override
  ngOnInit() {
    session = _sessionManager.session;
    if (!session.isAuth) {
      _router.navigate(["Dashboard", {}]);
    }
  }

  onSubmit(NgForm addUserForm) async {
    try {
      await _srvUser.createUser(user);
      success = true;
      error = false;
      addUserForm.controls.forEach((name, control) {
        control.updateValue('');
        control.setErrors(null);
      });
    } catch (e) {
      success = false;
      error = true;
    }
  }
}
