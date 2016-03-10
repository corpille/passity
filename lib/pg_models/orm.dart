part of pg_models;

class ORM {
  PostgreSql postgres;

  static final ORM _orm = new ORM._internal();

  factory ORM.fromPostgres(PostgreSql pg) {
    _orm.postgres = pg;
    return _orm;
  }

  factory ORM() {
    return _orm;
  }

  ORM._internal();
}
