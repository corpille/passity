part of api;

class Config {
  final configPath = "/config/config.yaml";

  Map configs;

  Config();

  Future getConfigs() async {
    var origin = Platform.script
        .toFilePath()
        .substring(0, Platform.script.path.lastIndexOf("/"));
    var file = new File(origin + configPath);
    var content = await file.readAsString(encoding: ASCII);
    configs = await loadYaml(content);
  }

  String getPostgreUri() {
    checkPostgreConfig();
    var config = configs["postgres"];
    return "postgres://" +
        config["login"] +
        ":" +
        config["password"] +
        "@" +
        config["url"] +
        ":" +
        config["port"] +
        "/" +
        config["dbName"] +
        "";
  }

  void checkPostgreConfig() {
    if (configs["postgres"] == null) {
      throw "Missing postgres configuration";
    }
    var config = configs["postgres"];
    List necessaryConfig = ["url", "port", "dbName", "login", "password"];
    necessaryConfig.forEach((configName) {
      if (config[configName] == null) {
        throw "Missing " + configName + " in postgres configuration";
      }
    });
  }
}
