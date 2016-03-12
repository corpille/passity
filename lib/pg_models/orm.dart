part of pg_models;

class Table {
  final String name;
  const Table([this.name]);
}

class OneToMany {
  const OneToMany();
}

class ManyToOne {
  const ManyToOne();
}

class ManyToMany {
  final bool main;
  const ManyToMany({this.main});
}

class ORM {
  PostgreSql _postgres;

  static final ORM _orm = new ORM._internal();

  factory ORM.fromPostgres(PostgreSql pg) {
    _orm._postgres = pg;
    return _orm;
  }

  factory ORM() {
    return _orm;
  }

  ORM._internal();

  Future query(String sql, [Type type, values]) async {
    if (values != null) {
      return await _postgres.query(sql, type, values);
    } else if (type != null) {
      return await _postgres.query(sql, type);
    } else {
      List rows = await _postgres.innerConn.query(sql).toList();
      List l = new List();
      for (var row in rows) {
        l.add(row.toMap());
      }
      return l;
    }
  }

  Future execute(String sql, [values]) async {
    List<String> queries = sql.split(";");
    if (queries.length == 1) {
      if (values != null) {
        return await _postgres.execute(sql, values);
      }
      return await _postgres.execute(sql);
    }

    for (String query in queries) {
      if (query != "") {
        if (values != null) {
          await _postgres.execute(query, values);
        }
        await _postgres.execute(query);
      }
    }
    return true;
  }
}
