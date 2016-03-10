part of api;

@app.Interceptor(r'/.*')
handleResponseHeader() async {
  if (app.request.method != "OPTIONS") {
    //process the chain and wrap the response
    await app.chain.next();
  }
  return app.response.change(headers: {
    'Access-Control-Allow-Headers':
        'Origin, X-Requested-With, Content-Type, Accept, authorization',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE'
  });
}

Future initPostgres(Config config) async {
  var dbManager = new PostgreSqlManager(config.getPostgreUri(), min: 1, max: 3);
  var postgreSql = await dbManager.getConnection();
  new ORM.fromPostgres(postgreSql);
  bootstrapMapper();
  await TableCreator.createTables(postgreSql);
  var credential = config.getAdminCredential();
  if (credential != null) {
    await TableCreator.createAdminUser(
        postgreSql, credential["login"], credential["password"]);
  }
  return dbManager;
}

main(List<String> args) async {
  initCipher();
  var config = new Config();
  await config.getConfigs();

  var dbManager = await initPostgres(config);

  var parser = new ArgParser();
  parser.addOption('port', abbr: 'p', defaultsTo: "8001");
  var results = parser.parse(args);

  app.showErrorPage = false;
  app.addPlugin(SecurityPlugin);
  app.addPlugin(getMapperPlugin(dbManager));
  app.setupConsoleLog();
  app.start(port: int.parse(results['port']));
}
