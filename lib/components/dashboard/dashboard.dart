part of components;

@Component(
    selector: 'dashboard',
    templateUrl: 'dashboard/dashboard.html',
    directives: const [RouterLink])
class Dashboard implements OnInit {
  Session session;
  final Router _router;
  final RouteParams _routeParams;
  final SessionManager _sessionManager;

  Dashboard(this._router, this._routeParams, this._sessionManager);

  @override
  ngOnInit() {
    session = _sessionManager.session;
    if (session.isAuth == false) {
      _router.navigate(["SignIn", {}]);
    }
  }
}
