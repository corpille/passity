part of passity;

class User {
  String login;

  String password;

  String key;

  User(this.login, this.password) {
    generateKey();
    password = Encryption.SHA512(password);
  }

  void generateKey() {
    var randomString = Utils.randomString(Encryption.KEY_SIZE);
    var token = Encryption.SHA256(Encryption.SHA512(password));
    var tokenChain = Utils.createUint8ListFromHexString(token);
    var encoded = Encryption.AES(randomString, tokenChain);
    key = Utils.formatBytesAsHexString(encoded);
  }

  String toString() {
    return "{\n" + "\tlogin: ${login},\n" + "\tpassword: ${password},\n" + "\tkey: ${key},\n" + "}";
  }
}
