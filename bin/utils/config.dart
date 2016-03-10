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
    if (configs["postgres"] == null || !(configs["postgres"] is Map)) {
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

  Map<String, String> getAdminCredential() {
    if (configs["admin_login"] == null ||
        !(configs["admin_login"] is Map) ||
        configs["admin_login"]["login"] == null ||
        !(configs["admin_login"]["login"] is String) ||
        configs["admin_login"]["login"] == "" ||
        configs["admin_login"]["password"] == null ||
        !(configs["admin_login"]["password"] is String) ||
        configs["admin_login"]["password"] == "") {
      return null;
    }
    return {
      "login": configs["admin_login"]["login"],
      "password": configs["admin_login"]["password"]
    };
  }
}
