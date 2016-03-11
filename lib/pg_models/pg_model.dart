part of pg_models;

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
      await new ORM().execute("select * from " + tableName);
    } catch (e) {
      var query = "create table " + tableName + " (";
      var subquery = "";
      List<VariableMirror> variables = _getClassVariable(im.type);
      for (int i = 0; i < variables.length; i++) {
        var varName = MirrorSystem.getName(variables[i].simpleName);

        var isManyToOne = hasAnnotation(variables[i], ManyToOne);
        var isManyToMany = hasAnnotation(variables[i], ManyToMany);
        if (isManyToMany != null) {
          subquery += await _createManyToManyTable(isManyToMany, variables[i]);
        } else {
          if (varName == "id") {
            query += "id uuid primary key";
          } else if (isManyToOne != null) {
            var typeName = MirrorSystem.getName(variables[i].type.simpleName);
            typeName = typeName.toLowerCase() + "_id";
            query += typeName + " text";
          } else {
            query += varName + " " + matchType(variables[i].type);
          }
          query += (i + 1 == variables.length) ? ")" : ", ";
        }
      }
      var finaleQuery = (subquery == "") ? query : query + ";" + subquery;
      await new ORM().execute(finaleQuery);
    }
  }

  Future _createManyToManyTable(
      ManyToMany relation, VariableMirror variable) async {
    String firstTable = getTableName(variable.owner).toLowerCase();
    if (variable.type.originalDeclaration.simpleName == #List) {
      TypeMirror relationType = variable.type.typeArguments.first;
      String secondTable =
          getTableName(relationType.originalDeclaration).toLowerCase();
      return await createRelationTable(firstTable, secondTable);
    }
    return "";
  }

  Future createRelationTable(String firstTable, String secondTable) async {
    var table_name = firstTable + "_" + secondTable;
    var query = "CREATE TABLE " + table_name + " (";
    query += "${firstTable}_id UUID,";
    query += "${secondTable}_id UUID,";
    query +=
        "CONSTRAINT ${firstTable}_${secondTable}_pk PRIMARY KEY (${firstTable}_id, ${secondTable}_id),";
    query +=
        "CONSTRAINT FK_${firstTable} FOREIGN KEY (${firstTable}_id) REFERENCES ${firstTable} (id),";
    query +=
        "CONSTRAINT FK_${secondTable} FOREIGN KEY (${secondTable}_id) REFERENCES ${secondTable} (id));";
    return query;
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
    var isUpdate = true;
    if (id == null) {
      var uuid = new Uuid();
      id = uuid.v4();
      isUpdate = false;
    }
    InstanceMirror im = reflect(this);
    List<VariableMirror> variables = _getClassVariable(im.type);
    String tableName = getTableName(im.type);
    if (tableName == null) {
      throw "Class has no table annotation";
    }
    String query = "";
    if (isUpdate) {
      query = "update ${tableName} SET ";
      variables.removeWhere((variable) {
        return MirrorSystem.getName(variable.simpleName) == "id";
      });
    } else {
      query = "insert into ${tableName} ";
    }
    String names = "(";
    String contents = "(";
    var subquery = "";
    for (int i = 0; i < variables.length; i++) {
      String varName = MirrorSystem.getName(variables[i].simpleName);
      var isManyToOne = hasAnnotation(variables[i], ManyToOne);
      var isManyToMany = hasAnnotation(variables[i], ManyToMany);
      if (isManyToMany != null) {
        subquery = await _handleSaveManyToMany(im, variables[i]);
      } else {
        var name = "";
        var content = "";
        if (isManyToOne != null) {
          var typeName = MirrorSystem.getName(variables[i].type.simpleName);
          name = typeName.toLowerCase() + "_id";
        } else {
          name += varName;
        }
        InstanceMirror f = im.getField(variables[i].simpleName);
        content = _typedVar(variables[i].type, f.reflectee);

        if (isUpdate) {
          query +=
              name + "=" + content + ((i + 1 == variables.length) ? "" : ", ");
        } else {
          names += name + ((i + 1 == variables.length) ? ")" : ", ");
          contents += content + ((i + 1 == variables.length) ? ")" : ", ");
        }
      }
    }
    if (!isUpdate) {
      query += names + " VALUES " + contents;
    } else if (isUpdate && subquery != "") {
      query = query.substring(0, query.length - 2);
    }
    var finaleQuery = (subquery == "") ? query : query + ";" + subquery;
    await new ORM().execute(finaleQuery);
    return this;
  }

  Future _handleSaveManyToMany(
      InstanceMirror im, VariableMirror variable) async {
    if (variable.type.originalDeclaration.simpleName == #List) {
      List<PgModel> relations = im.getField(variable.simpleName).reflectee;
      if (relations.length > 0) {
        String firstTable = getTableName(variable.owner).toLowerCase();
        TypeMirror relationType = variable.type.typeArguments.first;
        String secondTable =
            getTableName(relationType.originalDeclaration).toLowerCase();
        String query =
            "SELECT * from ${firstTable}_${secondTable} WHERE ${firstTable}_id = '${id}' AND (";
        for (int i = 0; i < relations.length; i++) {
          if (relations[i].id == null) {
            throw "One of the relation does not have an id";
          }
          query += secondTable + "_id = '${relations[i].id}'";
          query += (i + 1 == relations.length) ? ")" : " OR ";
        }
        List<Map> rels = await new ORM().query(query);
        relations.removeWhere((relation) {
          for (Map rel in rels) {
            if (relation.id == rel[secondTable + "_id"]) {
              return true;
            }
          }
          return false;
        });
        var realQuery = "";
        for (PgModel relation in relations) {
          realQuery +=
              "insert into ${firstTable}_${secondTable} (${firstTable}_id, ${secondTable}_id) VALUES ('${id}', '${relation.id}');";
        }
        return realQuery;
      }
    }
    return "";
  }

  Future delete() async {
    InstanceMirror im = reflect(this);
    String tableName = getTableName(im.type);
    if (tableName == null) {
      throw "Class has no table annotation";
    }
    String query = "delete from " + tableName + " where id = '${id}'";
    await new ORM().execute(query);
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
        await new ORM().query(query, im.reflectee.runtimeType);
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
      if (m.reflectee is Field ||
          m.reflectee is ManyToOne ||
          m.reflectee is ManyToMany) {
        res = true;
      }
    });
    return res;
  }

  hasAnnotation(VariableMirror variable, Type type) {
    var res = null;
    variable.metadata.forEach((m) {
      if (m.reflectee.runtimeType == type) {
        res = m.reflectee;
      }
    });
    return res;
  }
}

class Datetime {}
