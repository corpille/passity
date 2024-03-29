part of components;

@Component(
    selector: 'dashboard', templateUrl: 'dashboard/dashboard.component.html', directives: const [RouterLink, NgClass])
class Dashboard implements OnInit {
  Session session;
  bool showModal = false;
  bool showModalDeletion = false;
  String currentPasswordId = null;
  final Router _router;
  final SessionManager _sessionManager;
  final SrvPassword srvPassword;

  Dashboard(this._router, this._sessionManager, this.srvPassword);

  @override
  ngOnInit() {
    session = _sessionManager.session;
    if (session.isAuth == false) {
      return _router.navigate(["SignIn", {}]);
    }
    srvPassword.getPasswordByUser(session.user.id);
  }

  copyPassword() {
    InputElement input = DOM.query("#realPassword");
    input.onFocus.listen((e) {});
    input.select();
    document.execCommand('copy', null, "");
    input.blur();
    input.onFocus.listen((e) {
      input.blur();
    });
  }

  showPassword(String id) async {
    InputElement input = DOM.query("#realPassword");
    input.value = await srvPassword.getDecodePassword(id);
    showModal = true;
  }

  hidePassword() {
    InputElement input = DOM.query("#realPassword");
    input.value = "";
    showModal = false;
  }

  showDeletionModal(String id) {
    currentPasswordId = id;
    showModalDeletion = true;
  }

  hideDeletionModal() {
    currentPasswordId = null;
    showModalDeletion = false;
  }

  deletePassword() async {
    await srvPassword.deletePassword(currentPasswordId);
    showModalDeletion = false;
  }
}
