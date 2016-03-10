part of pg_models;

class Table {
  final String name;
  const Table([this.name]);
}

class ManyToOne {
  const ManyToOne();
}

abstract class PgModel {
  @Field()
  String id;

  Future createTable(postgreSql) async {
    InstanceMirror im = reflect(this);
    String tableName = getTableName(im.type);
    if (tableName == null) {
      throw "Class has no table annotation";
    }
    try {
      await postgreSql.execute("select * from " + tableName);
    } catch (e) {
      var query = "create table " + tableName + " (";
      List<VariableMirror> variables = _getClassVariable(im.type);
      for (int i = 0; i < variables.length; i++) {
        var varName = MirrorSystem.getName(variables[i].simpleName);
        if (varName == "id") {
          query += "id uuid primary key";
        } else if (hasAnnotation(variables[i], ManyToOne)) {
          var typeName = MirrorSystem.getName(variables[i].type.simpleName);
          typeName = typeName.toLowerCase() + "_id";
          query += typeName + " text";
        } else {
          query += varName + " " + matchType(variables[i].type);
        }
        query += (i + 1 == variables.length) ? ")" : ", ";
      }
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

  Future save() async {
    var uuid = new Uuid();
    id = uuid.v4();
    InstanceMirror im = reflect(this);
    List<VariableMirror> variables = _getClassVariable(im.type);
    String tableName = getTableName(im.type);
    if (tableName == null) {
      throw "Class has no table annotation";
    }
    String query = "insert into " + tableName + " ";
    String names = "(";
    String content = "(";
    for (int i = 0; i < variables.length; i++) {
      String varName = MirrorSystem.getName(variables[i].simpleName);
      if (hasAnnotation(variables[i], ManyToOne)) {
        var typeName = MirrorSystem.getName(variables[i].type.simpleName);
        names += typeName.toLowerCase() + "_id";
      } else {
        names += varName;
      }
      InstanceMirror f = im.getField(variables[i].simpleName);
      content += _typedVar(variables[i].type, f.reflectee);
      names += (i + 1 == variables.length) ? ")" : ", ";
      content += (i + 1 == variables.length) ? ")" : ", ";
    }
    query += names + " VALUES " + content;
    print(query);
    await new ORM().postgres.execute(query);
    return this;
  }

  Future delete() async {
    InstanceMirror im = reflect(this);
    String tableName = getTableName(im.type);
    if (tableName == null) {
      throw "Class has no table annotation";
    }
    String query = "delete from " + tableName + " where id = '${id}'";
    await new ORM().postgres.execute(query);
    return this;
  }

  Future findById(String id) async {
    InstanceMirror im = reflect(this);
    String tableName = getTableName(im.type);
    if (tableName == null) {
      throw "Class has no table annotation";
    }
    String query = "SELECT * from " + tableName + " WHERE id = '${id}'";
    List<PgModel> models =
        await new ORM().postgres.query(query, im.reflectee.runtimeType);
    if (models.length > 0) {
      return models.first;
    }
    return null;
  }

  String _typedVar(TypeMirror mType, dynamic value) {
    if (value == null) {
      return "NULL";
    }
    if (mType.reflectedType == String) {
      return "'" + value + "'";
    } else if (value is PgModel) {
      return "'" + value.id + "'";
    } else {
      return value.toString();
    }
  }

  static String getTableName(ClassMirror cm) {
    var table;
    cm.metadata.forEach((InstanceMirror metadata) {
      if (metadata.reflectee is Table) {
        table = metadata.reflectee.name;
      }
    });
    if (table == null) {
      table = MirrorSystem.getName(cm.simpleName).toLowerCase();
    }
    return table;
  }

  List<VariableMirror> _getClassVariable([ClassMirror cm]) {
    if (cm == null) {
      cm = reflect(this).type;
    }
    List<VariableMirror> variables = new List();
    cm.declarations.forEach((Symbol s, d) {
      if (d is VariableMirror) {
        if (isField(d)) {
          variables.add(d);
        }
      }
    });
    if (cm.superclass != null) {
      variables.addAll(_getClassVariable(cm.superclass));
    }
    return variables;
  }

  bool isField(VariableMirror variable) {
    var res = false;
    variable.metadata.forEach((m) {
      if (m.reflectee is Field || m.reflectee is ManyToOne) {
        res = true;
      }
    });
    return res;
  }

  bool hasAnnotation(VariableMirror variable, Type type) {
    var res = false;
    variable.metadata.forEach((m) {
      if (m.reflectee.runtimeType == type) {
        res = true;
      }
    });
    return res;
  }
}

class Datetime {}
