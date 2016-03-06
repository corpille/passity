part of components;

@Component(
    selector: 'my-app',
    templateUrl: 'components/app/app_component.html',
    directives: const [RouterOutlet, RouterLink])
@RouteConfig(const [
  const Route(
      path: '/sign-in',
      name: "SignIn",
      component: SignInComponent,
      useAsDefault: true),
  const Route(path: '/', name: "Dashboard", component: DashboardComponent)
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
