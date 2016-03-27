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
      List<VariableMirror> variables = _getFieldsVariable(im.type);
      for (int i = 0; i < variables.length; i++) {
        var varName = MirrorSystem.getName(variables[i].simpleName);

        var isManyToOne = hasAnnotation(variables[i], ManyToOne);
        var isManyToMany = hasAnnotation(variables[i], ManyToMany);
        if (isManyToMany != null && (isManyToMany as ManyToMany).main == true) {
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

  Future _createManyToManyTable(ManyToMany relation, VariableMirror variable) async {
    String firstTable = getTableName(variable.owner).toLowerCase();
    if (variable.type.originalDeclaration.simpleName == #List) {
      TypeMirror relationType = variable.type.typeArguments.first;
      String secondTable = getTableName(relationType.originalDeclaration).toLowerCase();
      return await createRelationTable(firstTable, secondTable);
    }
    return "";
  }

  Future createRelationTable(String firstTable, String secondTable) async {
    var table_name = firstTable + "_" + secondTable;
    var query = "CREATE TABLE " + table_name + " (";
    query += "${firstTable}_id UUID,";
    query += "${secondTable}_id UUID,";
    query += "CONSTRAINT ${firstTable}_${secondTable}_pk PRIMARY KEY (${firstTable}_id, ${secondTable}_id),";
    query += "CONSTRAINT FK_${firstTable} FOREIGN KEY (${firstTable}_id) REFERENCES ${firstTable} (id),";
    query += "CONSTRAINT FK_${secondTable} FOREIGN KEY (${secondTable}_id) REFERENCES ${secondTable} (id));";
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
    List<VariableMirror> variables = _getFieldsVariable(im.type);
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
      if (isManyToMany != null && (isManyToMany as ManyToMany).main == true) {
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
          query += name + "=" + content + ((i + 1 == variables.length) ? "" : ", ");
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

  Future _handleSaveManyToMany(InstanceMirror im, VariableMirror variable) async {
    if (variable.type.originalDeclaration.simpleName == #List) {
      List<PgModel> relations = im.getField(variable.simpleName).reflectee;
      if (relations.length > 0) {
        String firstTable = getTableName(variable.owner).toLowerCase();
        TypeMirror relationType = variable.type.typeArguments.first;
        String secondTable = getTableName(relationType.originalDeclaration).toLowerCase();
        String query = "SELECT * from ${firstTable}_${secondTable} WHERE ${firstTable}_id = '${id}' AND (";
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
    List<VariableMirror> variables = _getFieldsVariable(im.type);
    var subquery = "";
    for (int i = 0; i < variables.length; i++) {
      var isManyToMany = hasAnnotation(variables[i], ManyToMany);
      if (isManyToMany != null && (isManyToMany as ManyToMany).main == true) {
        subquery += await _deleteManyToMany(im, variables[i]);
      }
    }
    String query = "delete from ${tableName} where id = '${id}'";
    await new ORM().execute(subquery + query);
    return this;
  }

  Future _deleteManyToMany(InstanceMirror im, VariableMirror variable) async {
    if (variable.type.originalDeclaration.simpleName == #List) {
      List<PgModel> relations = im.getField(variable.simpleName).reflectee;
      if (relations.length > 0) {
        String firstTable = getTableName(variable.owner).toLowerCase();
        TypeMirror relationType = variable.type.typeArguments.first;
        String secondTable = getTableName(relationType.originalDeclaration).toLowerCase();
        return "delete from ${firstTable}_${secondTable} where ${firstTable}_id = '${id}';";
      }
    }
    return "";
  }

  Future findById(String id) async {
    InstanceMirror im = reflect(this);
    String tableName = getTableName(im.type);
    if (tableName == null) {
      throw "Class has no table annotation";
    }
    Map data = new Map();
    data.addAll(await _getOneToManyRelations(im, id));
    data.addAll(await _getManyToManyRelations(im, id));

    String query = "SELECT * from " + tableName + " WHERE id = '${id}'";
    List<PgModel> models = await new ORM().query(query, im.reflectee.runtimeType);
    if (models.length > 0) {
      var model = models.first;
      InstanceMirror i = reflect(model);
      data.forEach((key, value) {
        i.setField(key, value);
      });
      return model;
    }
    return null;
  }

  Future _getManyToManyRelations(InstanceMirror im, String id) async {
    List<VariableMirror> oneToMany = _getVarWithAnnotation(im, ManyToMany);
    Map data = new Map();
    for (VariableMirror relation in oneToMany) {
      ManyToMany rel = hasAnnotation(relation, ManyToMany);
      String firstTable = getTableName(relation.owner).toLowerCase();
      TypeMirror relationType = relation.type.typeArguments.first;
      String secondTable = getTableName(relationType.originalDeclaration).toLowerCase();
      var joinTable = (rel.main) ? "${firstTable}_${secondTable}" : "${secondTable}_${firstTable}";
      String query = "SELECT m.* FROM ${secondTable} m ";
      query += "JOIN ${joinTable} j ON j.${secondTable}_id = m.id ";
      query += "WHERE j.${firstTable}_id = '${id}'";
      List<PgModel> models = await new ORM().query(query, relationType.originalDeclaration.reflectedType);
      data[relation.simpleName] = models;
    }
    return data;
  }

  Future _getOneToManyRelations(InstanceMirror im, String id) async {
    List<VariableMirror> oneToMany = _getVarWithAnnotation(im, OneToMany);
    Map data = new Map();
    for (VariableMirror relation in oneToMany) {
      String firstTable = getTableName(relation.owner).toLowerCase();
      TypeMirror relationType = relation.type.typeArguments.first;
      String secondTable = getTableName(relationType.originalDeclaration).toLowerCase();
      String query = "select m.* FROM ${secondTable} m ";
      query += "WHERE m.${firstTable}_id = '${id}'";
      List<PgModel> models = await new ORM().query(query, relationType.originalDeclaration.reflectedType);
      data[relation.simpleName] = models;
    }
    return data;
  }

  List<VariableMirror> _getVarWithAnnotation(InstanceMirror im, Type type) {
    List<VariableMirror> res = new List();
    im.type.declarations.forEach((Symbol s, variable) {
      if (variable is VariableMirror) {
        if (hasAnnotation(variable, type) != null) {
          res.add(variable);
        }
      }
    });
    return res;
  }

  String toString() {
    return JSON.encode(toJson());
  }

  Map toJson() {
    InstanceMirror im = reflect(this);
    Map content = new Map();
    List<VariableMirror> variables = _getClassVariable();
    for (VariableMirror variable in variables) {
      String varName = MirrorSystem.getName(variable.simpleName);
      var data = im.getField(variable.simpleName).reflectee;
      if (data != null) {
        content[varName] = data;
      }
    }
    return content;
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
        variables.add(d);
      }
    });
    if (cm.superclass != null) {
      variables.addAll(_getFieldsVariable(cm.superclass));
    }
    return variables;
  }

  List<VariableMirror> _getFieldsVariable([ClassMirror cm]) {
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
      variables.addAll(_getFieldsVariable(cm.superclass));
    }
    return variables;
  }

  bool isField(VariableMirror variable) {
    var res = false;
    variable.metadata.forEach((m) {
      if (m.reflectee is Field || m.reflectee is ManyToOne || m.reflectee is ManyToMany) {
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
