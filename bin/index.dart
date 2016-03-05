part of api;

main() async {
  var config = new Config();
  await config.getConfigs();

  var dbManager = new PostgreSqlManager(config.getPostgreUri(), min: 1, max: 3);

  app.addPlugin(getMapperPlugin(dbManager));
  app.setupConsoleLog();
  app.start();
}
