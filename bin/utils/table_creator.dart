part of api;

class TableCreator {
  static Future createTables(PostgreSql postgreSql) async {
    MirrorSystem mirrorSystem = currentMirrorSystem();
    LibraryMirror library;
    mirrorSystem.libraries.forEach((lk, LibraryMirror l) {
      var name = MirrorSystem.getName(l.qualifiedName);
      if (name == "pg_models") {
        library = l;
      }
    });
    List<PgModel> models = new List();
    library.declarations.forEach((Symbol dk, DeclarationMirror d) {
      var table;
      d.metadata.forEach((InstanceMirror metadata) {
        if (metadata.reflectee is Table) {
          table = metadata.reflectee.name;
        }
      });
      if (table != null) {
        if (d is ClassMirror) {
          ClassMirror cm = d;
          InstanceMirror im = cm.newInstance(new Symbol(''), []);
          models.add(im.reflectee);
        }
      }
    });
    for (PgModel model in models) {
      await model.createTable(postgreSql);
    }
  }

  static Future createAdminUser(PostgreSql postgreSql, String login, String password) async {
    User user = new User();
    user.login = login;
    user.key = Encryption.generateKey(password);
    user.password = Encryption.SHA256(password);
    List<User> users = await postgreSql.query("SELECT * from users WHERE login = '${user.login}'", User);
    if (users != null && users.length == 0) {
      await user.save();
    }
  }
}
