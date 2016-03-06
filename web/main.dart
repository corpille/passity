import 'package:angular2/bootstrap.dart';
import 'package:angular2/router.dart';
import 'package:passity/components.dart';
import "package:passity/dao.dart";
import "package:passity/session.dart";

main() async {
  var dao = new Dao.fromUrl("/api");
  var sessionManager = new SessionManager.fromDao(dao);
  await sessionManager.isStillAuth().then((_) {
    bootstrap(AppComponent, [SessionManager, ROUTER_PROVIDERS]);
  });
}
