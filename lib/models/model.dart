part of models;

class Table {
  final String name;

  const Table([this.name]);
}

abstract class Model {
  @Field()
  String id;

  Future createTable(postgreSql) async {
    InstanceMirror im = reflect(this);
    ClassMirror cm = im.type;
    var table;
    cm.metadata.forEach((InstanceMirror metadata) {
      if (metadata.reflectee is Table) {
        table = metadata.reflectee.name;
      }
    });
    if (table == null) {
      table = MirrorSystem.getName(cm.simpleName).toLowerCase();
    }
    try {
      await postgreSql.execute("select * from " + table);
    } catch (e) {
      var query = "create table " + table + " (";
      query += "id uuid primary key default gen_random_uuid()";
      cm.declarations.forEach((Symbol s, d) {
        if (d is VariableMirror) {
          d.metadata.forEach((m) {
            if (m.reflectee is Field) {
              query += ", " +
                  MirrorSystem.getName(d.simpleName) +
                  " " +
                  matchType(d.type);
            }
          });
        }
      });
      query += ")";
      await postgreSql.execute(query);
    }
  }

  String matchType(TypeMirror mType) {
    switch (mType.reflectedType) {
      case bool:
        return "boolean";
      case int:
        return "int";
      case double:
        return "float";
      case Datetime:
        return "timestamp";
      case Map:
        return "json";
      case List:
        return "json";
    }
    return "text";
  }

  /// Transform the current class into a Map
  /// in order to be treated by the JSON functions
  Map toJson() {
    Map map = new Map();
    if (this.id != null && this.id != "") {
      map["id"] = this.id;
    }
    return map;
  }

  void checkData(Map data) {
    if (data.containsKey('id') &&
        data['id'] is String &&
        data['id'].isNotEmpty) {
      id = data['id'];
    }
  }

  String toString() {
    return JSON.encode(toJson());
  }
}

class Datetime {}
