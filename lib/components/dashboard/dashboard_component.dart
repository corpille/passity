part of components;

@Component(
    selector: 'dashboard',
    templateUrl: 'components/dashboard/dashboard_component.html')
class DashboardComponent implements OnInit {
  Session session;
  final Router _router;
  final RouteParams _routeParams;
  final SessionManager _sessionManager;

  DashboardComponent(this._router, this._routeParams, this._sessionManager);

  @override
  ngOnInit() {
    session = _sessionManager.session;
    if (session.isAuth == false) {
      _router.navigate(["SignIn", {}]);
    }
  }
}
