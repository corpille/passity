import 'package:angular2/bootstrap.dart';
import 'package:angular2/router.dart';
import 'package:passity/components/components.dart';
import "package:passity/dao.dart";
import "package:passity/session/sessions.dart";
import "package:passity/services/services.dart";

main() async {
  var dao = new Dao.fromUrl("/api");
  var sessionManager = new SessionManager.fromDao(dao);
  await sessionManager.isStillAuth().then((_) {
    bootstrap(AppComponent, [SessionManager, SrvPassword, SrvUser, ROUTER_PROVIDERS]);
  });
}
