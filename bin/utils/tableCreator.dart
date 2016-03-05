part of api;

class TableCreator {
  static Future createTables(PostgreSql postgreSql) async {
    MirrorSystem mirrorSystem = currentMirrorSystem();
    LibraryMirror library;
    mirrorSystem.libraries.forEach((lk, LibraryMirror l) {
      var name = MirrorSystem.getName(l.qualifiedName);
      if (name == "models") {
        library = l;
      }
    });
    List<Model> models = new List();
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
    for (Model model in models) {
      await model.createTable(postgreSql);
    }
  }
}
