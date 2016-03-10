part of components;

@Component(
    selector: 'my-app',
    templateUrl: 'app/app.html',
    directives: const [RouterOutlet, RouterLink])
@RouteConfig(const [
  const Route(path: '/sign-in', name: "SignIn", component: SignIn),
  const Route(path: '/', name: "Dashboard", component: Dashboard),
  const Route(
      path: '/add-password', name: "AddPassword", component: AddPassword)
])
class AppComponent {
  SessionManager _sessionManager;
  final Router _router;

  get session => _sessionManager.session;

  AppComponent(this._router, this._sessionManager) {}

  logout() async {
    await _sessionManager.logout();
    _router.navigate(["SignIn", {}]);
  }
}
